//
//  File.swift
//  Should I Run
//
//  Created by Roger Goldfinger on 8/3/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

//parse google results

//results = array of routes

//goes through each route.
//checks bart - bart will return the Route if it is bart
//same for muni

//if results is empty, call the error handler

import MapKit

protocol ParseGoogleHelperDelegate {
    func didReceiveGoogleResults(results: [Route])
    func handleError(errorMessage: String)
    
}

class ParseGoogleHelper {
    
    var delegate:ParseGoogleHelperDelegate? = nil
    
    func getLineCodeFromMuniStep(step:NSDictionary) -> String {
        if let transit_details = step.objectForKey("transit_details") as? NSDictionary {
            if let line:NSDictionary = transit_details.objectForKey("line") as? NSDictionary {
                var shortName = line.objectForKey("short_name") as NSString
                return shortName
            }
        }
        self.handleError(message:"There was a problem parsing results...")
        return "error"
        
    }
    
    func getLineNameFromTransitStep(step:NSDictionary) -> String {
        if let transit_details = step.objectForKey("transit_details") as? NSDictionary {
            if let line:NSDictionary = transit_details.objectForKey("line") as? NSDictionary {
                var lineName = line.objectForKey("name") as NSString
                return lineName
            }
        }
        self.handleError(message:"There was a problem parsing results...")
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
        
        // other issues we need to address:
        // `Fisherman's Wharf via Downtown`
        eolStationName = eolStationName.stringByReplacingOccurrencesOfString(" via Downtown", withString: "")
        eolStationName = eolStationName.stringByReplacingOccurrencesOfString("'", withString: "")
        
        
        return eolStationName
    }
    
    func getEolStationNameFromBartStep(step: NSDictionary) -> String {
        
        var instructions:NSString = step.objectForKey("html_instructions") as NSString
        

        var eolStationName = "error" // if it's not a bus or light rail, send back an error
        
        eolStationName = instructions.substringFromIndex(19).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        //get code for station
        
        if let code = bartLookup[eolStationName]?.uppercaseString {
            return code
        }
        
        return "error getting bart station code"

    }
    
    func getEolStationNameFromCaltrainStep(step: NSDictionary) -> String {
        //"html_instructions" = "Train towards San Jose Caltrain Station";
        
        var instructions:NSString = step.objectForKey("html_instructions") as NSString
        
        
        var eolStationName = "error" // if it's not a bus or light rail, send back an error
        
        eolStationName = instructions.substringFromIndex(13).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        return eolStationName
        
    }
    
    
    
    func getOriginStationNameFromTransitStep(step: NSDictionary) -> String {
        
        if let transit_details = step.objectForKey("transit_details") as? NSDictionary {
            if let departureStop:NSDictionary = transit_details.objectForKey("departure_stop") as? NSDictionary {
                var stationName = departureStop.objectForKey("name") as NSString
                return stationName
            }
        } else {
            self.handleError(message:"There was a problem parsing results...")
            return "error"
        }
        return "error"
        
        //  "departure_stop" =                             {
        //        location =                                 {
        //            lat = "37.778675";
        //            lng = "-122.414995";
        //        };
        //        name = "Metro Civic Center Station/Outbd";
    }
    
    func getOriginStationLocationFromTransitStep(step: NSDictionary) -> CLLocationCoordinate2D? {
        
        var result:(lat: String, lon: String) = (lat: "", lon:"")
        
        if let endLocation = step.objectForKey("start_location") as? NSDictionary {
            
            if var lat = (endLocation.objectForKey("lat") as NSNumber).stringValue as String? {
                
                result.lat = lat
            }
            if let lon = (endLocation.objectForKey("lng") as NSNumber).stringValue as String? {
                result.lon = lon
            }
            var latDouble = (result.lat as NSString).doubleValue
            var lonDouble = (result.lon as NSString).doubleValue
            
            return CLLocationCoordinate2DMake(CLLocationDegrees(latDouble), CLLocationDegrees(lonDouble))
        } else {
            return nil
        }
    }
    
    func getDistanceFromWalkingStep(walkingStep: NSDictionary) -> Int? {
        
        if let distance = walkingStep.objectForKey("distance")?.objectForKey("value")?.integerValue as Int! {
            return distance
        } else {
            return nil
        }
        
    }
    
    func getDepartureTimeFromCaltrainStep(step: NSDictionary) -> Double {
        
        if let transit_details = step.objectForKey("transit_details") as? NSDictionary {
        
            if let departure_time = transit_details.objectForKey("departure_time") as? NSDictionary {
                if let time = departure_time.objectForKey("value")?.integerValue as Int! {
                
                    var diff = 978307200 // difference between unix and ios reference date
                    return Double(time - diff)
                }
            
            }
        }
        
        return 0
        
//        "departure_time" =                                 {
//            text = "10:15am";
//            "time_zone" = "America/Los_Angeles";
//            value = 1410714900;
//        };
    }
    
    func processMuniResultFromStep(steps: NSArray, index: Int, line: NSDictionary) -> Route? {
    
        var thisStep = steps[index] as NSDictionary
        
        var distanceToStation = 0
        if index != 0 {
            var walkingStep = steps[index - 1] as NSDictionary
            if let dist = getDistanceFromWalkingStep(walkingStep) {
                distanceToStation = dist
            }
        }
        
        let muniOriginStationName =  getOriginStationNameFromTransitStep(thisStep)
        
        let lineName = self.getLineNameFromTransitStep(thisStep)
        let lineCode = self.getLineCodeFromMuniStep(thisStep)
        let eolStationName = self.getEolStationNameFromMuniStep(thisStep)
        
        let originCoord = self.getOriginStationLocationFromTransitStep(thisStep)
        
        let thisResult = Route(distanceToStation: distanceToStation, originStationName: muniOriginStationName, lineName: lineName, eolStationName: eolStationName, originCoord2d: originCoord!, agency: "muni", departureTime: nil, lineCode: lineCode)
        
        return thisResult

    }
    
    func processBartResultFromStep(steps: NSArray, index: Int) -> Route? {

        var thisStep = steps[index] as NSDictionary
        var distanceToStation = 0
        if index != 0 {
            var walkingStep = steps[index - 1] as NSDictionary
            if let dist = getDistanceFromWalkingStep(walkingStep) {
                distanceToStation = dist
            }
        }
        
        let bartOriginStationName =  bartLookup[getOriginStationNameFromTransitStep(thisStep)]!
        
        let lineName = self.getLineNameFromTransitStep(thisStep)
        let eolStationName = self.getEolStationNameFromBartStep(thisStep)
        
        let originCoord = self.getOriginStationLocationFromTransitStep(thisStep)
        
        let thisResult = Route(distanceToStation: distanceToStation, originStationName: bartOriginStationName, lineName: lineName, eolStationName: eolStationName, originCoord2d: originCoord!, agency: "bart", departureTime: nil, lineCode: nil)
        
        return thisResult
    }
    
    func processCaltrainResultsFromStep(steps: NSArray, index: Int) -> Route? {
        
        var thisStep = steps[index] as NSDictionary
        var distanceToStation = 0
        if index != 0 {
            var walkingStep = steps[index - 1] as NSDictionary
            if let dist = getDistanceFromWalkingStep(walkingStep) {
                distanceToStation = dist
            }
        }
        
        let caltrainOriginStationName = getOriginStationNameFromTransitStep(thisStep)
        
        let lineName = self.getLineNameFromTransitStep(thisStep)
        let eolStationName = self.getEolStationNameFromCaltrainStep(thisStep)
        
        let originCoord = self.getOriginStationLocationFromTransitStep(thisStep)
        
        let departureTime = self.getDepartureTimeFromCaltrainStep(thisStep)
        
        
        let thisResult = Route(distanceToStation: distanceToStation, originStationName: caltrainOriginStationName, lineName: lineName, eolStationName: eolStationName, originCoord2d: originCoord!, agency: "caltrain", departureTime: departureTime, lineCode: nil)
        
        return thisResult
        
    }
    
    
    func getResultFromRoute(route: NSDictionary) -> Route? {

        if let legs = route.objectForKey("legs") as? [NSDictionary] {
            
            // for whatever reason legs is always an array with only one element
            if let steps = legs[0].objectForKey("steps") as? [NSDictionary] {
                
                // iterate through each step. We only look at the first four steps.
                // Why? because we don't want routes that involve more than one transit step before bart
                // at most we're willing to consider a route that has a bus ride first
                // this would put BART/MUNI at the fourth step: walking, bus, walking, BART
                for var i = 0; i < steps.count && i < 4; ++i {
                    
                    if let transit_details = steps[i].objectForKey("transit_details") as? NSDictionary {
                        if let line:NSDictionary = transit_details.objectForKey("line") as? NSDictionary {
                            
                            if let agencies = line.objectForKey("agencies") as? NSArray {
                                
                                if let name = agencies[0].objectForKey("name") as? String {
                                    
                                    if name == "Bay Area Rapid Transit" {
                                        return self.processBartResultFromStep(steps, index: i)
                                      
                                    } else if name == "San Francisco Municipal Transportation Agency" {
                                        if let vehicle = line.objectForKey("vehicle") as? NSDictionary {
                                            
                                            if let type = vehicle.objectForKey("type") as? String {
                                                
                                                if type == "TRAM" {

                                                    return self.processMuniResultFromStep(steps, index: i, line: line)
                                                } else {
                                                    
                                                    // here we can check that the bus directions aren't longer than a reasonable walking distance
                                                    // if so, return nil: the distance is too far to walk, and the person will have to take a bus, 
                                                    // and we don't support busses
                                                    if let dist = steps[i].objectForKey("distance")?.objectForKey("value") as? NSNumber {
                                                        if dist > 2000 {
                                                            return nil
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    } else if name == "Caltrain" {
                                        return self.processCaltrainResultsFromStep(steps, index: i)
                                        
                                    } else {
                                        // some other transit agency. Here we're just doing the same distance check 
                                        // to make sure we're not making the user walk too far
                                        
                                        
                                        if let dist = steps[i].objectForKey("distance")?.objectForKey("value") as? NSNumber {
                                            if dist > 2000 {
                                                return nil
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return nil
        
    }
    
    func parser (googleResults: NSDictionary) {

        var results = [Route]()
        
        func addToResultsIfUniq (thisRoute:Route) {
            //only append if the result is uniq, that is, has different origin and eol station
            var uniq = true
            for res in results {
                if res.eolStationName == thisRoute.eolStationName || res.originStationName == thisRoute.originStationName {
                    uniq = false
                }
            }
            if uniq {
                results.append(thisRoute)
            }
        }
        
        
        //main loop. Checks that allRoutes is valid, and then iterares through each route to scrape out bart or muni
        
        if let allRoutes = googleResults.objectForKey("routes") as? [AnyObject] {
            for route in allRoutes {
                
                if let result:Route = self.getResultFromRoute(route as NSDictionary) {
                    addToResultsIfUniq(result)
                }
                
            }
        }

        
        if results.count == 0 {
            self.handleError()
        } else {
            
            //check if any results are caltrain - if so remove others! 
            // we do this because google often provides bart or muni before caltrain - but we're going to assume they will walk to caltrain
            var caltrain = false
            var indiciesToRemove = [Int]()
            
            for result in results {
                if result.agency == "caltrain" {
                    caltrain = true
                }
            }
            
            if caltrain == true {
                for var i = 0; i < results.count; ++i {
                    if results[i].agency != "caltrain" {
                        indiciesToRemove.insert(i, atIndex: 0)
                    }
                }
                for index in indiciesToRemove {
                    results.removeAtIndex(index)
                }
            }
            
            self.delegate?.didReceiveGoogleResults(results)
        }
        
    }
    
    func handleError(message:String="Couldn't find any BART, MUNI, or Caltrain trips between those locations...") {
        self.delegate?.handleError(message)
        
    }
}