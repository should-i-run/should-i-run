//
//  GoogleApiController.swift
//  Should I Run
//
//  Created by Neil Lobo on 7/17/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import UIKit



protocol GoogleAPIControllerProtocol {
    func didReceiveGoogleData(data: NSDictionary)
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
    var locationUserData = [String: Any]()
    
    func fetchGoogleData(locName: String, latDest:Float, lngDest:Float, latStart:Float, lngStart:Float) {
        
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
                var cachedResults = item["results"] as NSDictionary
                
                self.delegate?.didReceiveGoogleData(cachedResults)
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
        
        self.delegate?.didReceiveGoogleData(jsonDict)
    }
    
    func handleError(message:String="Couldn't find any BART, MUNI, or Caltrain trips between here and there...") {
        self.delegate?.handleError(message)
        
    }
    
}
