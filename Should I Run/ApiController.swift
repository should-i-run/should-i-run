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
        
        var cache = fileManager.readFromCache()
        var time = Int(NSDate().timeIntervalSince1970)
        //checking if the location is cached && if the users location has not changed && if the results are not more than 5 min old
        for item in cache {
            var cachedLocaton = item["location"] as String
            var cachedPosition = item["position"] as Float
            var cachedTime = item["time"] as Int
            if ( cachedLocaton == locName && cachedPosition == latStart && (time - cachedTime < 100) ) {
                cachedLocationFound = true
                var cachedResults = JSON(item["results"] as AnyObject!)
                let routes = self.buildRoutes(cachedResults)
                self.delegate?.didReceiveData(routes)
                return
            }
        }
        
        if !cachedLocationFound {
            var url = "http://localhost:3000/?startLat=\(latStart)&startLon=\(lngStart)&destLat=\(latDest)&destLon=\(lngDest)&key=AIzaSyB9JV82Cy-GFPTAbYy3HgfZOG"
            println(url)
            
            Alamofire.request(.POST, url)
                .responseJSON { (req, res, jsonData, err) in
                    //TODO handle errors, no results
                    if let realJSON = jsonData? {
                        let json = JSON(realJSON)
                        if let jrray = json.array {
                            if jrray.count == 0 {
                                self.handleError()
                            }
                            self.cacheData(json.object)
                            let routes = self.buildRoutes(json)
                            self.delegate!.didReceiveData(routes)
                        } else {
                            self.handleError()
                        }
                    } else {
                        self.handleError()
                    }
                }
        }
    }
    
    func cacheData (data: AnyObject){
        var time = Int(NSDate().timeIntervalSince1970)
        var cache = self.fileManager.readFromCache()
        let datum = ["time" : time, "location" : self.locationUserData["locName"] as String, "position" : self.locationUserData["latStart"] as Float, "results" : data]
        cache.insertObject(datum, atIndex: cache.count)
        self.fileManager.saveToCache(cache)
    }
    
    func buildRoutes(routes: JSON) -> [Route] {
        return (routes.arrayValue).map( { (rt) -> Route in
            return self.parseRoute(rt)
            })
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
