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
import SwiftyJSON

class apiController: NSObject {

    static let instance = apiController()

    let fileManager = SharedFileManager

    // Store user location data so we can cache it with the server data
    var locationUserData = [String: Any]()
    var mostRecentApiResponse: Any?

    func fetchData(locName: String, latDest:Float, lngDest:Float, latStart:Float, lngStart:Float, success: ([Route] -> ()), fail: String -> ()) {
        self.locationUserData["locName"] = locName as String
        self.locationUserData["latStart"] = latStart as Float

        let cache = fileManager.readFromCache()
        let time = Int(NSDate().timeIntervalSince1970)
        var cachedLocationFound = false
        //checking if the location is cached && if the users location has not changed && if the results are not more than 5 min old
        for item in cache {
            let cachedLocaton = item["location"] as! String
            let cachedPosition = item["position"] as! Float
            let cachedTime = item["time"] as! Int
            if ( cachedLocaton == locName && cachedPosition == latStart && (time - cachedTime < 100) ) {
                cachedLocationFound = true
                let cachedResults = item["results"] as! String
                if let dataFromString = cachedResults.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                    let json = JSON(data: dataFromString)
                    let routes = self.buildRoutes(json)
                    success(routes)
                    return
                }
            }
        }

        if !cachedLocationFound {
            let url = "https://tranquil-harbor-8717.herokuapp.com/?startLat=\(latStart)&startLon=\(lngStart)&destLat=\(latDest)&destLon=\(lngDest)&key=AIzaSyB9JV82Cy-GFPTAbYy3HgfZOG"
            print(url)
            Alamofire.request(.POST, url)
                .responseJSON { response in
                    switch response.result {
                    case .Success(let data):
                        let json: JSON = JSON(data)
                        if json.count == 0 || json[0] == nil {
                            self.handleError(fail, message: "Sorry, no results")
                        } else {
                            self.cacheData(json)
                            let routes = self.buildRoutes(json)
                            success(routes)
                        }
                    case .Failure:
                        self.handleError(fail)
                    }
                }
        }
    }

    func cacheData (data: JSON){
        let time = Int(NSDate().timeIntervalSince1970)
        let stringData: String = data.rawString(NSUTF8StringEncoding)!
        
        let cache = self.fileManager.readFromCache()
        let datum = ["time" : time, "location" : self.locationUserData["locName"] as! String, "position" : self.locationUserData["latStart"] as! Float, "results" : stringData]
        self.mostRecentApiResponse = datum
        cache.insertObject(datum, atIndex: cache.count)
        self.fileManager.saveToCache(cache)
    }

    func buildRoutes(routes: JSON) -> [Route] {
        return (routes.arrayValue).filter({ $0 != nil}).map( { self.parseRoute($0)})
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
    
    func logApiResponse() {
        print(self.mostRecentApiResponse)
    }
}
