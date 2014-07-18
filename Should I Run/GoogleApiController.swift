//
//  GoogleApiController.swift
//  Should I Run
//
//  Created by Neil Lobo on 7/17/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import UIKit



protocol GoogleAPIControllerProtocol {
    func didReceiveGoogleResults(results: Array<String>!, error:String?)
}


class GoogleApiController: NSObject{
    
    
   

    var delegate : GoogleAPIControllerProtocol?
    
    func fetchGoogleData(latDest:Float, lngDest:Float, latStart:Float, lngStart:Float) {
                
        var time = Int(NSDate().timeIntervalSince1970)
        var url = NSURL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(latStart),\(lngStart)&destination=\(latDest),\(lngDest)&key=AIzaSyB9JV82Cy-GFPTAbYy3HgfZOGT75KVp-dg&departure_time=\(time)&mode=transit&alternatives=true")
        
        var request = NSURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
            (response, data, error) in

            
            if error {println("Error!!",error)}

            let jsonDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
           
            self.convertGoogleToBart(jsonDict)

        }
        
    }
   
    func convertGoogleToBart(goog: NSDictionary) {
        var results :Array<String> = []
        
        var walkingStepIndex = 0
        
        var foundBart : Bool = false
        var i:Int  = 1 //start at 1 because the first step is always walking
        var name1:String = ""
        var fname1:String = ""
        
        var allRoutes : NSArray = goog.objectForKey("routes") as NSArray
        
        var inter2 : NSArray = allRoutes[0].objectForKey("legs") as NSArray
        
        var steps : NSArray = inter2[0].objectForKey("steps") as NSArray
        
        //iterate over each step until we find the one with 
        //trainsit_detials / line / agencys [0] name
        
        func findBart(stepsArray: NSArray) -> NSDictionary? {
            var result:NSDictionary?
            
            for var i = 1; i < steps.count; ++i {

                if let transit_details = steps[i].objectForKey("transit_details") as? NSDictionary {

                    if let line:NSDictionary = transit_details.objectForKey("line") as? NSDictionary {

                        if let agencies = line.objectForKey("agencies") as? NSArray {

                            if let name = agencies[0].objectForKey("name") as? String {

                                if name == "Bay Area Rapid Transit" {
                                    result = steps[i] as NSDictionary

                                    walkingStepIndex = i - 1
                                    i = steps.count // we found bart, so skip out of our for loop
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
            var instructions = step.objectForKey("html_instructions") as String
            
            //trim off first 7 characters to get station name
            var originStationName = instructions.substringFromIndex(7).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            //get code for station
            var originStationCode = bartLookup[originStationName]?.uppercaseString
            
            
            result.append(originStationCode!)
            
            return result
        }

        func getEOLStationFromBartStep(step: NSDictionary) -> Array<String> {
            
            var result:[String] = []
            var instructions = step.objectForKey("html_instructions") as String
            
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

            
            //TODO: make the results list uniq
            return results
        }
        
        
        if let bartStep:NSDictionary = findBart(steps)? {
            results += getDistanceFromWalkingStep(steps[walkingStepIndex] as NSDictionary)
            results += getOriginStationFromWalkingStep(steps[walkingStepIndex] as NSDictionary)
            results += getAllEOLStations(allRoutes)
            
            self.delegate?.didReceiveGoogleResults(results, error: nil)

        } else {
            //error, no bart
            //TODO: trigger segue back to main screen with error
            println("No bart")
            self.delegate?.didReceiveGoogleResults(nil, error: "No bart")

        }
        
        


    }
}
