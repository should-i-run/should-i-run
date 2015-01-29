//
//  File.swift
//  Should I Run
//
//  Created by Roger Goldfinger on 8/3/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import UIKit
import MapKit

class Route {
    var departureTime: Double?
    var distanceToStation: Int?
    var originStationName: String
    var lineName: String
    var lineCode:String?
    var eolStationName: String
    var originLatLon:CLLocationCoordinate2D
    var agency: String
    
    init (originStationName: String, lineName: String, eolStationName: String, originCoord2d: CLLocationCoordinate2D, agency: String, departureTime: Double?, lineCode: String?, distanceToStation: Int?) {

        self.originStationName = originStationName
        self.lineName = lineName
        self.eolStationName = eolStationName
        self.agency = agency
        self.originLatLon = originCoord2d
        
        //initialise departure time, if it's around
        if let time = departureTime? {
            self.departureTime = time
        }
        if let code = lineCode? {
            self.lineCode = code
        }
        if let dist = distanceToStation? {
            self.distanceToStation = dist
        }
    }
    
}

func routesAreSame(routeA: Route, routeB: Route) -> Bool {
    return (routeA.originStationName == routeB.originStationName) &&
        (routeA.lineName == routeB.lineName)
}

func originsAreSame(routeA: Route, routeB: Route) -> Bool {
    return (routeA.originStationName == routeB.originStationName)
}

func routeInSet(routesSet: [Route], routeA: Route) -> Bool {
    return routesSet.reduce(false, combine: {
        (collectorBool, thisRoute) -> Bool in
        if (originsAreSame(thisRoute, routeA)) {
            return true
        } else {
            return collectorBool
        }
    })
}

func makeUniqRoutes(routes: [Route]) -> [Route] {
    var result = [Route]()
    for aRoute in routes {
        if !(routeInSet(result, aRoute)) {
            result.append(aRoute)
        }
    }
    return result
}

//func didReceiveMuniResults(results: [(departureTime: Int, distanceToStation: String, originStationName: String, lineName: String, eolStationName: String, originLatLon:(lat:String, lon:String))])