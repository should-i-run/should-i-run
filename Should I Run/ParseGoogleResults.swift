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
        self.handleError(message:"There was a problem getting BART results...")
        return "error"
        
    }
    
    func getLineNameFromTransitStep(step:NSDictionary) -> String {
        if let transit_details = step.objectForKey("transit_details") as? NSDictionary {
            if let line:NSDictionary = transit_details.objectForKey("line") as? NSDictionary {
                var lineName = line.objectForKey("name") as NSString
                return lineName
            }
        }
        self.handleError(message:"There was a problem getting BART results...")
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
    
    func getEolStationNameFromBartStep(step: NSDictionary) -> String {
        
        var instructions:NSString = step.objectForKey("html_instructions") as NSString
        

        var eolStationName = "error" // if it's not a bus or light rail, send back an error
        
        eolStationName = instructions.substringFromIndex(19).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        //get code for station
        
        if let code = bartLookup[eolStationName]?.uppercaseString {
            return code
        }
        
        return "error getting bar station code"

    }
    
    func getOriginStationNameFromTransitStep(step: NSDictionary) -> String {
        
        if let transit_details = step.objectForKey("transit_details") as? NSDictionary {
            if let departureStop:NSDictionary = transit_details.objectForKey("departure_stop") as? NSDictionary {
                var stationName = departureStop.objectForKey("name") as NSString
                return stationName
            }
        } else {
            self.handleError(message:"There was a problem getting MUNI results...")
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
    
    func getMuniResultFromGoogleRoute(route: NSDictionary) -> Route? {
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
                                                    
                                                    
                                                    var thisStep = steps[i] as NSDictionary
                                                    
                                                    var distanceToStation = 0
                                                    if i != 0 {
                                                        var walkingStep = steps[i - 1] as NSDictionary
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
        return nil
    }
    
    
    func getBartResultFromGoogleRoute(route: NSDictionary) -> Route? {
        if let legs = route.objectForKey("legs") as? [NSDictionary] {
            //for whatever reason legs is always an array with only one element
            if let steps = legs[0].objectForKey("steps") as? [NSDictionary] {
                for var i = 1; i < steps.count; ++i {
                    if let transit_details = steps[i].objectForKey("transit_details") as? NSDictionary {
                        
                        if let line:NSDictionary = transit_details.objectForKey("line") as? NSDictionary {
                            
                            if let agencies = line.objectForKey("agencies") as? NSArray {
                                
                                if let name = agencies[0].objectForKey("name") as? String {
                                    
                                    if name == "Bay Area Rapid Transit" {
                                        
                                        
                                        
                                        // now that we have the step, get the data
                                        
                                        
                                        var thisStep = steps[i] as NSDictionary
                                        
                                        var distanceToStation = 0
                                        if i != 0 {
                                            var walkingStep = steps[i - 1] as NSDictionary
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
                if let bartResult:Route = self.getBartResultFromGoogleRoute(route as NSDictionary) {
                    addToResultsIfUniq(bartResult)
                    

                } else if let muniResult:Route = self.getMuniResultFromGoogleRoute(route as NSDictionary) {
                    addToResultsIfUniq(muniResult)
                }
            }
        }


        
        if results.count == 0 {
            self.handleError()
        } else {
            self.delegate?.didReceiveGoogleResults(results)
        }
        
    }
    
    func handleError(message:String="Couldn't find any BART or MUNI trips between those locations...") {
        self.delegate?.handleError(message)
        
    }
}