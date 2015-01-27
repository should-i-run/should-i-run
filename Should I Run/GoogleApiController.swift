//
//  GoogleApiController.swift
//  Should I Run
//
//  Created by Neil Lobo on 7/17/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

protocol ApiControllerProtocol {
    func didReceiveData([Route])
    func handleError(errorMessage: String)
}

class apiController: NSObject {
    
    var delegate : ApiControllerProtocol?
    
    let fileManager = SharedFileManager
    
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
        
        if !cachedLocationFound {
            var url = "http://localhost:3000/?startLat=\(latStart)&startLon=\(lngStart)&destLat=\(latDest)&destLon=\(lngDest)&key=AIzaSyB9JV82Cy-GFPTAbYy3HgfZOG"
            
            Alamofire.request(.POST, url)
                .responseJSON { (req, res, jsonData, err) in
                    self.cacheData(jsonData)
                    let json = JSON(jsonData!)
                    var resArray = [Route]()
                    for (var i = 0; i < json.count; ++i) {
                        var x = self.parseRoute(json[i])
                        resArray.append(x)
                    }
                    self.delegate!.didReceiveData(resArray)
                }
        }
    }
    
    func cacheData (data: AnyObject?){
        
        var time = Int(NSDate().timeIntervalSince1970)

//        var cache = self.fileManager.readFromCache()
//        cache.insertObject(["time" : time, "location" : self.locationUserData["locName"] as String, "position" : self.locationUserData["latStart"] as Float, "results" : data], atIndex: cache.count)
//        self.fileManager.saveToCache(cache)

    }

    func parseRoute(route: JSON) -> Route {
        let latDouble : Double = route["originStationLatLon"]["lat"].double!
        let lonDouble : Double = route["originStationLatLon"]["lon"].double!
        let loc = CLLocationCoordinate2DMake(CLLocationDegrees(latDouble), CLLocationDegrees(lonDouble))
        
        let time = Double((route["departureTime"].doubleValue / 1000) - 978307200) // difference between unix and ios reference date

        return Route(originStationName: route["originStationName"].stringValue, lineName: route["lineName"].stringValue, eolStationName: route["eolStationName"].stringValue, originCoord2d: loc, agency: route["agency"].stringValue, departureTime: time, lineCode: nil, distanceToStation: nil)

    }
    
    func handleError(message:String="Couldn't find any BART, MUNI, or Caltrain trips between here and there...") {
        self.delegate?.handleError(message)
        
    }
    
}
