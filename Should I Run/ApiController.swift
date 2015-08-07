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

class apiController: NSObject {
    
    static let instance = apiController()
    
    let fileManager = SharedFileManager
    var cachedLocationFound = false
    
    // Store user location data so we can cache it with the server data
    var locationUserData = [String: Any]()
    
    func fetchData(locName: String, latDest:Float, lngDest:Float, latStart:Float, lngStart:Float, success: ([Route] -> ()), fail: String -> ()) {
        self.locationUserData["locName"] = locName as String
        self.locationUserData["latStart"] = latStart as Float
        
        let cache = fileManager.readFromCache()
        let time = Int(NSDate().timeIntervalSince1970)
        //checking if the location is cached && if the users location has not changed && if the results are not more than 5 min old
        for item in cache {
            let cachedLocaton = item["location"] as! String
            let cachedPosition = item["position"] as! Float
            let cachedTime = item["time"] as! Int
            if ( cachedLocaton == locName && cachedPosition == latStart && (time - cachedTime < 100) ) {
                cachedLocationFound = true
                let cachedResults = JSON(item["results"] as AnyObject!)
                let routes = self.buildRoutes(cachedResults)
                success(routes)
                return
            }
        }
        
        if !cachedLocationFound {
            let url = "http://tranquil-harbor-8717.herokuapp.com/?startLat=\(latStart)&startLon=\(lngStart)&destLat=\(latDest)&destLon=\(lngDest)&key=AIzaSyB9JV82Cy-GFPTAbYy3HgfZOG"
            print(url)
            Alamofire.request(.POST, url)
                .responseJSON { (req, res, jsonData) in
                    //TODO handle errors, no results
                    if let realJSON: AnyObject = jsonData.value! {
                        let json = JSON(realJSON)
                        if let jrray = json.array {
                            if jrray.count == 0 || jrray[0] == nil {
                                self.handleError(fail, message: "Sorry, no results")
                            } else {
                                self.cacheData(json.object)
                                let routes = self.buildRoutes(json)
                                success(routes)
                            }
                        } else {
                            self.handleError(fail)
                        }
                    } else {
                        self.handleError(fail)
                    }
                }
        }
    }
    
    func cacheData (data: AnyObject){
        let time = Int(NSDate().timeIntervalSince1970)
        let cache = self.fileManager.readFromCache()
        let datum = ["time" : time, "location" : self.locationUserData["locName"] as! String, "position" : self.locationUserData["latStart"] as! Float, "results" : data]
        cache.insertObject(datum, atIndex: cache.count)
        self.fileManager.saveToCache(cache)
    }
    
    func buildRoutes(routes: JSON) -> [Route] {
        return (routes.arrayValue).filter({ $0 != nil}).map( { (rt: JSON) -> Route in
            return self.parseRoute(rt)
        })
    }

    // Move this into an init function on the route
    func parseRoute(route: JSON) -> Route {
        let latDouble : Double = route["originStationLatLon"]["lat"].double!
        let lonDouble : Double = route["originStationLatLon"]["lon"].double!
        let loc = CLLocationCoordinate2DMake(CLLocationDegrees(latDouble), CLLocationDegrees(lonDouble))
        
        let time = Double((route["departureTime"].doubleValue / 1000) - 978307200) // difference between unix and ios reference date

        return Route(originStationName: route["originStationName"].stringValue, lineName: route["lineName"].stringValue, eolStationName: route["eolStationName"].stringValue, originCoord2d: loc, agency: route["agency"].stringValue, departureTime: time, lineCode: nil, distanceToStation: nil)
    }
    
    func handleError(fail: String -> (), message: String = "Couldn't find any BART, MUNI, or Caltrain trips between here and there...") {
        fail(message)
    }
}
