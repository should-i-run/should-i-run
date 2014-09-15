
//  MuniApiController.swift
//  Should I Run
//
//  Created by Roger Goldfinger on 7/23/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.


import UIKit



protocol MuniAPIControllerDelegate {
    func didReceiveMuniResults(results: [Route])
    func handleError(errorMessage: String)
    
}


class MuniApiController: NSObject{
    
    var delegate: MuniAPIControllerDelegate?
    
    // Create a reference to our MUNI API connection so we can cancel it later
    var currentMuniConnection: NSURLConnection?
    var currentMuniData: NSMutableData = NSMutableData()
    
    // Store user location data in this variable so we can use it once the Google API data is downloaded
    var dataFromGoogle: [Route]?
    
    // MARK: MUNI API Connection Methods
    
    // Cancel the MUNI API connection (on timeout)
    func cancelConnection() {
        self.currentMuniConnection?.cancel()
    }
    
    // If MUNI API connection fails, handle error here
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        self.delegate?.handleError("MUNI API connection failed")
    }
    
    // Append data as we receive it from the MUNI API
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        self.currentMuniData.appendData(data)
    }
    
    // On connection success, handle data we get from the MUNI API
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        self.processMuniData(currentMuniData, data: self.dataFromGoogle!)
    }
    
    
    // MARK: Search and Handle MUNI data
    
    func searchMuniFor(data:[Route]) {
        
        self.dataFromGoogle = data
        
        /*
        possible results from google:
        Metro Civic Center Station/Downtn -> muni wants Inbound
        Metro Civic Center Station/Outbd -> muni wants Outbound
        Powell Station/Outbound
        Market St & 7th St
        
        */
        //we are going to assume that there is only one origin station in the results.
        //otherwise two API calls would have been made
        var googleOriginStationName = data[0].originStationName
        
        var muniOriginStationName = googleOriginStationName.stringByReplacingOccurrencesOfString("&", withString: "and")
        
        //additionally, light rail station names need "muni " removed, and /outbd /inbd replaced with " outbound" etc
        muniOriginStationName = muniOriginStationName.stringByReplacingOccurrencesOfString("Metro ", withString: "")
        muniOriginStationName = muniOriginStationName.stringByReplacingOccurrencesOfString("/Outbd", withString: " Outbound")
        muniOriginStationName = muniOriginStationName.stringByReplacingOccurrencesOfString("/Outbound", withString: " Outbound")
        muniOriginStationName = muniOriginStationName.stringByReplacingOccurrencesOfString("/Inbd", withString: " Inbound")
        muniOriginStationName = muniOriginStationName.stringByReplacingOccurrencesOfString("/Inbound", withString: " Inbound")
        muniOriginStationName = muniOriginStationName.stringByReplacingOccurrencesOfString("/Downtn", withString: " Inbound")
        muniOriginStationName = muniOriginStationName.stringByReplacingOccurrencesOfString("/Downtown", withString: " Inbound")
        
        // build up url
        let baseUrl = "http://services.my511.org/Transit2.0/GetNextDeparturesByStopName.aspx?token=83d1f7f4-1d1e-4fc0-a070-162a95bd106f&agencyName=SF-MUNI&stopName="
        let escapedStationName = muniOriginStationName.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        //stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let url = NSURL(string: baseUrl + escapedStationName!)
        
        var request = NSURLRequest(URL: url)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        // Make a request to the MUNI API if no cached results are found
        self.currentMuniConnection = NSURLConnection.connectionWithRequest(request, delegate: self)
        
    }
    
    func processMuniData(rawMuniXML:NSData, data: [Route]){
        
        var muniRouteResults = [Route]()
        
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        
        let html = NSString(data: rawMuniXML, encoding: NSUTF8StringEncoding)
        
        
        let parsedXML: NSDictionary = XMLReader.dictionaryForXMLString(html, error: nil)
        
        // Trim off unneeded headers
        if let routes: NSDictionary = parsedXML.objectForKey("RTT")?.objectForKey("AgencyList")?.objectForKey("Agency")?.objectForKey("RouteList")? as? NSDictionary {
            
            //what's left should be an array of routes, but we'll check just in case
            var routesArray:[NSDictionary] = []
            
            if let temp:[NSDictionary] = routes.objectForKey("Route") as? [NSDictionary] {
                routesArray += temp
                
            } else if let temp:NSDictionary = routes.objectForKey("Route") as? NSDictionary {
                routesArray.append(temp)
            }
            
            
            let results:[String] = []
            
            for route in routesArray {
                
                for datum in data {

                    if route.objectForKey("Code") as? String == datum.lineCode {
                        
                        var routeDirections:NSArray?
                        
                        if let routeDirectionsArray = route.objectForKey("RouteDirectionList")?.objectForKey("RouteDirection") as? NSArray  {
                            routeDirections = routeDirectionsArray
                            
                        } else if let routeDirectionsDictionary = route.objectForKey("RouteDirectionList")?.objectForKey("RouteDirection") as? NSDictionary  {
                            routeDirections = [routeDirectionsDictionary]
                        }
                        
                        if routeDirections != nil {
                            
                            for direction in routeDirections! {

                                var directionName = direction.objectForKey("Name") as String
                                directionName = directionName.stringByReplacingOccurrencesOfString("Inbound to ", withString: "")
                                directionName = directionName.stringByReplacingOccurrencesOfString("Outbound to ", withString: "")
                                
                                if directionName == datum.eolStationName {
                                    
                                    if let departureTimeList  = direction.objectForKey("StopList")?.objectForKey("Stop")?.objectForKey("DepartureTimeList") as? NSDictionary {
                                        
                                        //what's left should be an array of departure times or a dictionary of a single time
                                        var departureTimesArray:[NSDictionary] = []
                                        
                                        if let temp:[NSDictionary] = departureTimeList.objectForKey("DepartureTime") as? [NSDictionary] {
                                            departureTimesArray += temp
                                            
                                        } else if let temp:NSDictionary = departureTimeList.objectForKey("DepartureTime") as? NSDictionary {
                                            departureTimesArray.append(temp)
                                        }

                                        for departureTime in departureTimesArray {
                                            let text = departureTime.objectForKey("text") as String

                                            let trimmedText = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

                                            
                                            
                                            
                                            
                                            var muniOriginStationName = datum.originStationName.stringByReplacingOccurrencesOfString("Metro ", withString: "")
                                            muniOriginStationName = muniOriginStationName.stringByReplacingOccurrencesOfString("/Outbd", withString: " Outbound")
                                            muniOriginStationName = muniOriginStationName.stringByReplacingOccurrencesOfString("/Outbound", withString: " Outbound")
                                            muniOriginStationName = muniOriginStationName.stringByReplacingOccurrencesOfString("/Inbd", withString: " Inbound")
                                            muniOriginStationName = muniOriginStationName.stringByReplacingOccurrencesOfString("/Inbound", withString: " Inbound")
                                            muniOriginStationName = muniOriginStationName.stringByReplacingOccurrencesOfString("/Downtn", withString: " Inbound")
                                            muniOriginStationName = muniOriginStationName.stringByReplacingOccurrencesOfString("/Downtown", withString: " Inbound")
                                            
                                            
                                            
                                            let lineName = "\(datum.lineCode!)—\(datum.lineName)"
                                            
                                            let departureTime = trimmedText.toInt()!
                                            let trainTime:Double = NSDate.timeIntervalSinceReferenceDate() + NSTimeInterval(departureTime * 60)

                                            
                                            var thisResult = Route(distanceToStation: datum.distanceToStation, originStationName: muniOriginStationName, lineName: lineName, eolStationName: datum.eolStationName, originCoord2d: datum.originLatLon, agency: datum.agency, departureTime: trainTime, lineCode: datum.lineCode)
                                            muniRouteResults.append(thisResult)
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                }
                
            }
            
            if muniRouteResults.count == 0 {
                self.delegate!.handleError("Couldn't find any Muni Light Rail directions...")
                return
            }
            
            muniRouteResults.sort{$0.departureTime < $1.departureTime}
            
            
            self.delegate!.didReceiveMuniResults(muniRouteResults)
            
        } else {
            self.delegate!.handleError("Couldn't find any Muni Light Rail directions...")
        }
    }
}

/*

<Agency Name="AC Transit" HasDirection="True" Mode="Bus"></Agency>
<Agency Name="BART" HasDirection="False" Mode="Rail"></Agency>
<Agency Name="Caltrain" HasDirection="True" Mode="Rail"></Agency>
<Agency Name="Dumbarton Express" HasDirection="True" Mode="Bus"></Agency>
<Agency Name="Marin Transit" HasDirection="True" Mode="Bus"></Agency>
<Agency Name="SamTrans" HasDirection="True" Mode="Bus"></Agency>
<Agency Name="SF-MUNI" HasDirection="True" Mode="Bus"></Agency>
<Agency Name="Vine (Napa County)" HasDirection="True" Mode="Bus"></Agency>
<Agency Name="VTA" HasDirection="True" Mode="Bus"></Agency>
<Agency Name="WESTCAT " HasDirection="True" Mode="Bus"></Agency>
</AgencyList>


http://services.my511.org/Transit2.0/GetRoutesForAgencies.aspx?token=83d1f7f4-1d1e-4fc0-a070-162a95bd106f&agencyNames=SF-MUNI

example route

<Route Name="71L-Haight Noriega Limited" Code="71L">
<RouteDirectionList>
<RouteDirection Code="Inbound" Name="Inbound to Downtown"></RouteDirection>
<RouteDirection Code="Outbound" Name="Outbound to The Sunset District"></RouteDirection>
</RouteDirectionList>
</Route>

route IDF Format
&routeIDF=AgencyName~RouteCode~RouteDirectionCode.

http://services.my511.org/Transit2.0/GetStopsForRoute.aspx?token=83d1f7f4-1d1e-4fc0-a070-162a95bd106f&routeIDF=SF-MUNI~71L~Outbound

<RTT>
<AgencyList>
<Agency Name="SF-MUNI" HasDirection="True" Mode="Bus">
<RouteList>
<Route Name="71L-Haight Noriega Limited" Code="71L">
<RouteDirectionList>
<RouteDirection Code="Outbound" Name="Outbound to The Sunset District">
<StopList>
<Stop name="23rd Ave and Irving St" StopCode="13441"></Stop>
<Stop name="23rd Ave and Judah St" StopCode="13442"></Stop>
<Stop name="23rd Ave and Kirkham St" StopCode="13443"></Stop>
<Stop name="23rd Ave and Lawton St" StopCode="13444"></Stop>
<Stop name="23rd Ave and Lincoln Way" StopCode="13445"></Stop>
<Stop name="23rd Ave and Moraga St" StopCode="13446"></Stop>
<Stop name="23rd Ave and Noriega St" StopCode="13447"></Stop>
<Stop name="Frederick St and Arguello Blvd" StopCode="14714"></Stop>
<Stop name="Frederick St and Stanyan St" StopCode="14718"></Stop>
<Stop name="Frederick St and Willard St" StopCode="14719"></Stop>
<Stop name="Fremont St and Market St" StopCode="14725"></Stop>
<Stop name="Haight St and Clayton St" StopCode="14946"></Stop>
<Stop name="Haight St and Cole St" StopCode="14948"></Stop>
<Stop name="Haight St and Divisadero St" StopCode="14950"></Stop>
<Stop name="Haight St and Fillmore St" StopCode="14952"></Stop>
<Stop name="Haight St and Gough St" StopCode="14954"></Stop>
<Stop name="Haight St and Laguna St" StopCode="14955"></Stop>
<Stop name="Haight St and Masonic Ave" StopCode="14957"></Stop>
<Stop name="Haight St and Stanyan St" StopCode="14962"></Stop>
<Stop name="Lincoln Way and 5th Ave" StopCode="15296"></Stop>
<Stop name="Lincoln Way and 7th Ave" StopCode="15298"></Stop>
<Stop name="Lincoln Way and 9th Ave" StopCode="15300"></Stop>
<Stop name="Lincoln Way and 11th Ave" StopCode="15302"></Stop>
<Stop name="Lincoln Way and 15th Ave" StopCode="15304"></Stop>
<Stop name="Lincoln Way and 17th Ave" StopCode="15306"></Stop>
<Stop name="Lincoln Way and 19th Ave" StopCode="15309"></Stop>
<Stop name="Lincoln Way and 21st Ave" StopCode="15310"></Stop>
<Stop name="Lincoln Way and Funston Ave" StopCode="15326"></Stop>
<Stop name="Mission St and Beale St" StopCode="15579"></Stop>
<Stop name="Market St and 2nd St" StopCode="15639"></Stop>
<Stop name="Market St and 5th St North" StopCode="15655"></Stop>
<Stop name="Market St and 7th St North" StopCode="15656"></Stop>
<Stop name="Market St and Battery St" StopCode="15657"></Stop>


light rail result:
[323, Metro Civic Center Station/Outbd, L, Taraval, San Francisco Zoo]

bus result:
[142, Market St & 7th St, 71, Haight-Noriega, the Sunset District]

http://services.my511.org/Transit2.0/GetNextDeparturesByStopName.aspx?token=83d1f7f4-1d1e-4fc0-a070-162a95bd106f&agencyName=MUNI&stopName=Metro Civic Center Station/Outbd

*/
