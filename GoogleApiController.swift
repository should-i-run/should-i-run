//
//  GoogleApiController.swift
//  Should I Run
//
//  Created by Neil Lobo on 7/17/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import UIKit

protocol APIControllerProtocol {
    func didReceiveAPIResults(results: NSArray)
}

class GoogleApiController: NSObject {
   
    func convertGoogleToBart(goog: NSDictionary) ->  Array<String> {
        var results :Array<String> = []
        
        var foundWalking : Bool = false
        var i:Int  = 0
        var name1:String = ""
        var fname1:String = ""
        
        
        
        var inter : NSArray = goog.objectForKey("routes") as NSArray
        
        
        var inter2 : NSArray = inter[0].objectForKey("legs") as NSArray
        
        var steps : NSArray = inter2[0].objectForKey("steps") as NSArray
        
        
        while(!foundWalking){
            if steps[i].objectForKey("travel_mode") as String == "WALKING" {
                foundWalking = true
                
                name1 = steps[i].objectForKey("html_instructions") as String
                fname1 = name1.substringFromIndex(7).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
                
                //                    println("Only Station 1 name is \(fname1)")
                var stn1 = bartLookup[fname1]
                //                println("Bart Lookup for Station 1 is \(stn1)")
                
                var distance = steps[i].objectForKey("distance") as NSDictionary
                
                results.append(String(distance["value"].intValue))
                results.append(stn1!.uppercaseString)
                
            } else if i == steps.count {
                foundWalking = true
                println("No Valid Transit Directions")
            }else {
                i++
            }
        }
        
        i++
        
        var fname2:String = ""
        var name2:String = steps[i].objectForKey("html_instructions") as String
        
        fname2 = name2.substringFromIndex(19).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        //         println("Only Station 2 name is \(fname2)")
        
        var stn2 = bartLookup[fname2];
        println("Bart Lookup for Station 2 is \(stn2)")
        
        results.append(stn2!.uppercaseString)
        
        
        
        i = 0;
        var k: Int = 1
        
        while k < inter.count {
            
            var inter2 = inter[k].objectForKey("legs") as NSArray
            var steps : NSArray = inter2[0].objectForKey("steps") as NSArray
            
            foundWalking = false;
            
            while(!foundWalking){
                if (steps[i]? && steps[i].objectForKey("travel_mode")? && steps[i].objectForKey("travel_mode") as String == "WALKING"){
                    foundWalking = true
                } else if i+1 >= steps.count {
                    foundWalking = true
                } else {
                    i++
                }
            }
            
            i++
            if i < steps.count {
                name2 = steps[i].objectForKey("html_instructions") as String
                name2 = name2.substringFromIndex(19)
            }
            
            if bartLookup[name2]{
                stn2 = bartLookup[name2]
                results.append(stn2!.uppercaseString)
            }
            k++
            
        }
        println(results)
        return results
    }

}
