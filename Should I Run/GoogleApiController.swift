//
//  GoogleApiController.swift
//  Should I Run
//
//  Created by Neil Lobo on 7/17/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import UIKit
import MapKit


protocol ApiControllerProtocol {
    func didReceiveData([Route])
    func handleError(errorMessage: String)
}


class apiController: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    
    var delegate : ApiControllerProtocol?
    
    let fileManager = SharedFileManager
    
    // Create a reference to our Google API connection so we can cancel it later
    var currentConnection: NSURLConnection?
    var currentData: NSMutableData = NSMutableData()
    
    var cachedLocationFound = false
    
    // Store user location data so we can cache it with the server data
    var locationUserData = [String: Any]()
    
    func fetchData(locName: String, latDest:Float, lngDest:Float, latStart:Float, lngStart:Float) {
        
        self.locationUserData["locName"] = locName as String
        self.locationUserData["latStart"] = latStart as Float
        
        
        //opening the local cache where we are caching google results to prevent repeated API calls in a short time
        var cache = fileManager.readFromCache()
        
        
        var time = Int(NSDate().timeIntervalSince1970)
        
        //checking if the location is cached && if the users location has not changed && if the results are not more than 5 min old
        for item in cache {
            var cachedLocaton = item["location"] as String
            var cachedPosition = item["position"] as Float
            var cachedTime = item["time"] as Int
            if ( cachedLocaton == locName && cachedPosition == latStart && (time - cachedTime < 600) ) {
                cachedLocationFound = true
                var cachedResults = item["results"] as [Route]
                
                self.delegate?.didReceiveData(cachedResults)
                return
            }
        }
        
        
        var url = NSURL(string: "http://localhost:3000/?startLat=\(latStart),startLon=\(lngStart)&destLat=\(latDest),destLon=\(lngDest)&key=AIzaSyB9JV82Cy-GFPTAbYy3HgfZOG")
        
        var request = NSURLRequest(URL: url!)
        if !cachedLocationFound {
            
            // Make a request to the Google API if no cached results are found
            self.currentConnection = NSURLConnection(request: request, delegate: self)
            
        }
        
    }
    
    // MARK: Google API Connection Methods
    
    // Cancel the Google API connection (on timeout)
    func cancelConnection() {
        self.currentConnection?.cancel()
    }
    
    // If Google API connection fails, handle error here
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        self.delegate?.handleError("Google API connection failed")
    }
    
    // Append data as we receive it from the Google API
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        self.currentData.appendData(data)
    }
    
    // On connection success, handle data we get from the Google API
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        
        let jsonDict = NSJSONSerialization.JSONObjectWithData(self.currentData, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
        println(jsonDict)
        var time = Int(NSDate().timeIntervalSince1970)
        
        //saving the fetched results to the local cache
        var cache = self.fileManager.readFromCache()
        cache.insertObject(["time" : time, "location" : self.locationUserData["locName"] as String, "position" : self.locationUserData["latStart"] as Float, "results" : jsonDict], atIndex: cache.count)
        self.fileManager.saveToCache(cache)

        let results = self.parseData(jsonDict)
        
        self.delegate?.didReceiveData(results)
    }

    func parseData(data: NSDictionary) -> [Route] {
        var x: [Route] = []
        var latDouble = ("234523452" as NSString).doubleValue
        var lonDouble = ("23452435345" as NSString).doubleValue
        
        var loc = CLLocationCoordinate2DMake(CLLocationDegrees(latDouble), CLLocationDegrees(lonDouble))

        x.append(Route(distanceToStation: 6, originStationName: "dsfg", lineName: "fgsdfg", eolStationName: "asdf asdf", originCoord2d: loc, agency: "caltrain", departureTime: 3523453452345234, lineCode: nil))
        return x

    }
    
    func handleError(message:String="Couldn't find any BART, MUNI, or Caltrain trips between here and there...") {
        self.delegate?.handleError(message)
        
    }
    
}
