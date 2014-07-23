//
//  MuniApiController.swift
//  Should I Run
//
//  Created by Roger Goldfinger on 7/23/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.


import UIKit



protocol MuniAPIControllerDelegate {
    func didReceiveMuniResults(results: Array<String>!, error:String?)

}


class MuniApiController: NSObject{
    
    var delegate: MuniAPIControllerDelegate?
    
    func searchMuniFor(data: [String]) {
        
        //83d1f7f4-1d1e-4fc0-a070-162a95bd106f
        //data: [distance to station, station name, line code, line name, EOL station]
        //hack reactor
        //lat 37.780948
        //-122.414045
        
        //taraval st
        //37.74261,-122.491207
        
        /*
        possible results from google:
            Metro Civic Center Station/Downtn -> muni wants Inbound
            Metro Civic Center Station/Outbd -> muni wants Outbound
            Market St & 7th St
        
        */
        
        var googleOriginStationName = data[1]
        println("station name from google: \(googleOriginStationName)")

        
        var muniOriginStationName = googleOriginStationName.stringByReplacingOccurrencesOfString("&", withString: "and")
        
        //additionally, light rail station names need "muni " removed, and /outbd /inbd replaced with " outbound" etc
        muniOriginStationName = muniOriginStationName.stringByReplacingOccurrencesOfString("Metro ", withString: "")
        muniOriginStationName = muniOriginStationName.stringByReplacingOccurrencesOfString("/Outbd", withString: " Outbound")
        muniOriginStationName = muniOriginStationName.stringByReplacingOccurrencesOfString("/Inbd", withString: " Inbound")
        muniOriginStationName = muniOriginStationName.stringByReplacingOccurrencesOfString("/Downtn", withString: " Inbound")
        
        println("station name from google: \(muniOriginStationName)")

        
        // build up url
        var baseUrl = "http://services.my511.org/Transit2.0/GetNextDeparturesByStopName.aspx?token=83d1f7f4-1d1e-4fc0-a070-162a95bd106f&agencyName=SF-MUNI&stopName="
        var escapedStationName = muniOriginStationName.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let url = NSURL(string: baseUrl + escapedStationName)
        
        var request = NSURLRequest(URL: url)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            self.processMuniData(data, andError: error)
            })
        
    }
    
    func processMuniData(data:NSData?, andError error:NSError?){
        if let err = error? {
            //handle error
            
        } else if let rawMuniXML = data? {
            var result:[String] = []
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            
            let html = NSString(data: data, encoding: NSUTF8StringEncoding)
            
            let parsed: NSDictionary = XMLReader.dictionaryForXMLString(html, error: nil)
            
            // Trim off unneeded data inside the dictionary
            let stations: NSDictionary = parsed.objectForKey("root").objectForKey("station") as NSDictionary
            
            self.delegate!.didReceiveMuniResults(result, error: nil)
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
