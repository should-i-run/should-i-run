//
//  GoogleApiController.swift
//  Should I Run
//
//  Created by Neil Lobo on 7/17/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import UIKit



protocol GoogleAPIControllerProtocol {
    func didReceiveGoogleResults(results: [String])
    func didReceiveGoogleResults(results: [(distanceToStation: String, muniOriginStationName: String, lineCode: String, lineName: String, eolStationName: String, originLatLon:(lat:String, lon:String))], muni: Bool)
    func handleError(errorMessage: String)
}


class GoogleApiController: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    
    var delegate : GoogleAPIControllerProtocol?
    
    let fileManager = SharedFileManager
    
    // Create a reference to our Google API connection so we can cancel it later
    var currentGoogleConnection: NSURLConnection?
    var currentGoogleData: NSMutableData = NSMutableData()
    
    var cachedLocationFound = false
    
    // Store user location data in this variable so we can use it once the Google API data is downloaded
    var locationUserData = Dictionary<String, Any>()
    
    func fetchGoogleData(locName: String, latDest:Float, lngDest:Float, latStart:Float, lngStart:Float) {
      
        self.locationUserData["locName"] = locName as String
        self.locationUserData["latStart"] = latStart as Float

        
        //opening the local cache where we are caching google results to prevent repeated API calls in a short time
        
        var cache = fileManager.readFromCache()
        
//var cache = NSMutableArray(contentsOfFile: NSBundle.mainBundle().pathForResource("Cache", ofType: "plist"))

        var time = Int(NSDate().timeIntervalSince1970)

        //checking if the location is cached && if the users location has not changed && if the results are not more than 5 min old
        for item in cache {
            var cachedLocaton = item["location"] as String
            var cachedPosition = item["position"] as Float
            var cachedTime = item["time"] as Int
            if ( cachedLocaton == locName && cachedPosition == latStart && (time - cachedTime < 600) ) {
                cachedLocationFound = true
                var cachedResults = item["results"] as NSDictionary
                
                self.parseGoogleTransitData(cachedResults)
                return
            }
        }
       

        var url = NSURL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(latStart),\(lngStart)&destination=\(latDest),\(lngDest)&key=AIzaSyB9JV82Cy-GFPTAbYy3HgfZOGT75KVp-dg&departure_time=\(time)&mode=transit&alternatives=true")
        
        var request = NSURLRequest(URL: url)
        if !cachedLocationFound {

            // Make a request to the Google API if no cached results are found
            self.currentGoogleConnection = NSURLConnection.connectionWithRequest(request, delegate: self)

        }
        
    }
    
// MARK: Google API Connection Methods

    // Cancel the Google API connection (on timeout)
    func cancelConnection() {
        println("cancelling Google API request")
        self.currentGoogleConnection?.cancel()
    }
    
    // If Google API connection fails, handle error here
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        self.delegate?.handleError("Google API connection failed")
    }
    
    // Append data as we receive it from the Google API
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        self.currentGoogleData.appendData(data)
    }
    
    // On connection success, handle data we get from the Google API
    func connectionDidFinishLoading(connection: NSURLConnection!) {

        let jsonDict = NSJSONSerialization.JSONObjectWithData(self.currentGoogleData, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
        var time = Int(NSDate().timeIntervalSince1970)
        
        //saving the fetched results to the local cache
        var cache = self.fileManager.readFromCache()
        cache.insertObject(["time" : time, "location" : self.locationUserData["locName"] as String, "position" : self.locationUserData["latStart"] as Float, "results" : jsonDict], atIndex: cache.count)
        self.fileManager.saveToCache(cache)

        self.parseGoogleTransitData(jsonDict)
    }
    
// MARK: Data Handling Methods
    
    func parseGoogleTransitData(goog: NSDictionary) {
        var results :[String] = []
        
        var walkingStepIndex = 0
        
        
        var allRoutes = goog.objectForKey("routes") as [NSDictionary]
        var inter2 : NSArray = allRoutes[0].objectForKey("legs") as NSArray
        var steps : NSArray = inter2[0].objectForKey("steps") as NSArray
        
//Bart helper functions
        func findBart(stepsArray: NSArray) -> NSDictionary? {
            var result:NSDictionary?
            
            for var i = 1; i < steps.count; ++i {

                if let transit_details = steps[i].objectForKey("transit_details") as? NSDictionary {

                    if let line:NSDictionary = transit_details.objectForKey("line") as? NSDictionary {

                        if let agencies = line.objectForKey("agencies") as? NSArray {

                            if let name = agencies[0].objectForKey("name") as? String {

                                if name == "Bay Area Rapid Transit" {
                                    result = (steps[i] as NSDictionary)
                                    walkingStepIndex = i - 1
                                    return result
                                }
                            }
                        }
                    }
                }
            }
            return result
        }
        
        func getDistanceFromWalkingStep(walkingStep: NSDictionary) -> String {
            var result:String = ""
            
            var distanceDictinary = walkingStep.objectForKey("distance") as NSDictionary
            
            var distance = String(distanceDictinary.objectForKey("value").intValue) //stored as an int so we need to conver t to string
            
            result = distance
            
            return result
        }
        
        func getOriginStationFromWalkingStep(step: NSDictionary) -> Array<String> {
            
            var result:[String] = []
            var instructions:NSString = step.objectForKey("html_instructions") as NSString
            
            //trim off first 7 characters to get station name

            var originStationName = instructions.substringFromIndex(7)
                .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            //get code for station
            var originStationCode = bartLookup[originStationName]!.uppercaseString
            
            
            result.append(originStationCode)
            
            return result
        }
        
        func getOriginStationLocationFromWalkingStep(step: NSDictionary) -> (lat: String, lon: String) {
            
            var result:(lat: String, lon: String) = (lat: "", lon:"")
            
            if let endLocation = step.objectForKey("end_location") as? NSDictionary {

                if var lat = (endLocation.objectForKey("lat") as NSNumber).stringValue {

                    result.lat = lat
                }
                if let lon = (endLocation.objectForKey("lng") as NSNumber).stringValue  {
                    result.lon = lon
                }
            }

            return result
        }

        func getEOLStationFromBartStep(step: NSDictionary) -> Array<String> {
            
            var result:[String] = []
            var instructions:NSString = step.objectForKey("html_instructions") as NSString
            
            //trim off first 7 characters to get station name
            
            var eolStationName = instructions.substringFromIndex(19).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            //get code for station

            var eolStationCode = bartLookup[eolStationName]?.uppercaseString
            result.append(eolStationCode!)
            return result
        }
        
        func getAllEOLStations(routes: NSArray) -> [String] {
            var results:[String]  = []
            
            //iterate through each route and get the EOL station
            for var i = 1; i < routes.count; ++i {
                var legs : NSArray = routes[i].objectForKey("legs") as NSArray
                var steps : NSArray = legs[0].objectForKey("steps") as NSArray
                if let bartStep:NSDictionary = findBart(steps)? {
                    results += getEOLStationFromBartStep(bartStep)
                }
            }
            return results
        }
        
// muni helper functions
        
        func getMuniOriginStationFromWalkingStep(step: NSDictionary) -> String {
            
            var instructions:NSString = step.objectForKey("html_instructions") as NSString
            
            //trim off first 7 characters to get station name
            var originStationName = instructions.substringFromIndex(7)
                .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            return originStationName
        }
        
        func getLineCodeFromMuniStep(step:NSDictionary) -> String {
            if let transit_details = step.objectForKey("transit_details") as? NSDictionary {
                if let line:NSDictionary = transit_details.objectForKey("line") as? NSDictionary {
                    var shortName = line.objectForKey("short_name") as NSString
                    return shortName
                }
            }
            self.delegate?.handleError("There was a problem getting BART results...")
            return "Error"
        }
        
        func getLineNameFromMuniStep(step:NSDictionary) -> String {
            if let transit_details = step.objectForKey("transit_details") as? NSDictionary {
                if let line:NSDictionary = transit_details.objectForKey("line") as? NSDictionary {
                    var lineName = line.objectForKey("name") as NSString
                    return lineName
                }
            }
            self.delegate?.handleError("There was a problem getting BART results...")
            return "error"
        }

        func getEolStationNameFromMuniStep(step:NSDictionary) -> String {

            var instructions:NSString = step.objectForKey("html_instructions") as NSString
            
            // google will return two possible results here:
            // "Bus towards the Sunset District"
            // "Light rail towards Balboa Park Station via Downtown"
            // so we need to check the first character, which will determine the length of what needs to be sliced off
            // NSString.characterAtIndex(0) -> returns a character code
            // B == 66
            // L == 76
            var eolStationName = "error" // if it's not a bus or light rail, send back an error
            
            if instructions.characterAtIndex(0) == 66 {
                eolStationName = instructions.substringFromIndex(12).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
            } else if instructions.characterAtIndex(0) == 76 {
                eolStationName = instructions.substringFromIndex(18).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
            }
            
            return eolStationName
        }
        
        func getMuniData(allRoutes: [NSDictionary]) -> [(distanceToStation: String, muniOriginStationName: String, lineCode: String, lineName: String, eolStationName: String, originLatLon:(lat:String, lon:String))]? {
            var result:[(distanceToStation: String, muniOriginStationName: String, lineCode: String, lineName: String, eolStationName: String, originLatLon:(lat:String, lon:String))] = []
            for route in allRoutes  {
                if let legs = route.objectForKey("legs") as? [NSDictionary] {
                    //for whatever reason legs is always an array with only one element
                    if let steps = legs[0].objectForKey("steps") as? [NSDictionary] {
                        for var i = 1; i < steps.count; ++i {
                            
                            if let transit_details = steps[i].objectForKey("transit_details") as? NSDictionary {
                                
                                if let line:NSDictionary = transit_details.objectForKey("line") as? NSDictionary {
                                    
                                    if let agencies = line.objectForKey("agencies") as? NSArray {
                                        
                                        if let name = agencies[0].objectForKey("name") as? String {
                                            
                                            if name == "San Francisco Municipal Transportation Agency" {
                                                
                                                //For now, limiting to light rail by checking the vehicle type
                                                //comment out this block to remove the limitation
                                                if let vehicle = line.objectForKey("vehicle") as? NSDictionary {
                                                    
                                                    if let type = vehicle.objectForKey("type") as? String {
                                                        
                                                        if type == "TRAM" {
                                                            //but keep this part
                                                            
                                                            // now that we have the step, get the data
                                                            
                                                            var thisResult: (distanceToStation: String, muniOriginStationName: String, lineCode: String, lineName: String, eolStationName: String, originLatLon:(lat:String, lon:String))
                                                            var thisStep = steps[i] as NSDictionary
                                                            var walkingStep = steps[i - 1] as NSDictionary
                                                            
                                                            thisResult.distanceToStation =  getDistanceFromWalkingStep(walkingStep)
                                                            thisResult.muniOriginStationName =  getMuniOriginStationFromWalkingStep(walkingStep)
                                                            thisResult.lineCode = getLineCodeFromMuniStep(thisStep)
                                                            thisResult.lineName = getLineNameFromMuniStep(thisStep)
                                                            thisResult.eolStationName = getEolStationNameFromMuniStep(thisStep)
                                                            thisResult.originLatLon = getOriginStationLocationFromWalkingStep(walkingStep)
                                                            
                                                            result.insert(thisResult, atIndex: result.count)
                                                            //return to commenting
                                                        }
                                                    }
                                                }
                                                //end commenting
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if result.count == 0 {
                return nil
            } else {
                return result
            }
        }


        
        if let bartStep:NSDictionary = findBart(steps)? {
            results += getDistanceFromWalkingStep(steps[walkingStepIndex] as NSDictionary)
            results += getOriginStationFromWalkingStep(steps[walkingStepIndex] as NSDictionary)
            results += getAllEOLStations(allRoutes)
            var (lat, lon) = getOriginStationLocationFromWalkingStep(steps[walkingStepIndex] as NSDictionary)
            results += lat
            results += lon
            
            self.delegate?.didReceiveGoogleResults(results)

        } else if let muniData = getMuniData(allRoutes)? {
            self.delegate?.didReceiveGoogleResults(muniData, muni: true)
            
        } else {
            self.delegate?.handleError("Couldn't find any BART or MUNI trips between here and there")

        }
    }
}
