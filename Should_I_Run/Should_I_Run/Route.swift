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
    var shouldRun: Bool
    let stationTime = 2
    
    var walkingTime = 0
    var runningTime = 0
    
    let formatter = NSDateComponentsFormatter()
    let dateComponent = NSDateComponents()
    
    init (originStationName: String, lineName: String, eolStationName: String, originCoord2d: CLLocationCoordinate2D, agency: String, departureTime: Double?, lineCode: String?, distanceToStation: Int?) {

        self.originStationName = originStationName
        self.lineName = lineName
        self.eolStationName = eolStationName
        self.agency = agency
        self.originLatLon = originCoord2d

        self.departureTime = departureTime
        self.lineCode = lineCode
        self.distanceToStation = distanceToStation
        self.shouldRun = false
        self.formatter.unitsStyle = .Positional
    }
    
    func getCurrentMinutes() -> Int {
      return Int(self.departureTime! - NSDate.timeIntervalSinceReferenceDate()) / 60
    }
    
    func getFormattedTime() -> String {
        let min = self.getCurrentMinutes()
        let sec = Int(self.departureTime! - NSDate.timeIntervalSinceReferenceDate()) % 60
        self.dateComponent.minute = min
        self.dateComponent.second = sec
        return self.formatter.stringFromDateComponents(self.dateComponent)!
    }
    
    func toString() -> String {
        return "self.originStationName \(self.originStationName)\n" +
        "self.lineName \(self.lineName)\n" +
        "self.eolStationName \(self.eolStationName)\n" +
        "self.agency \(self.agency)\n" +
        "self.originLatLon \(self.originLatLon)\n" +
        "self.departureTime \(self.departureTime)\n" +
        "self.lineCode \(self.lineCode)\n" +
        "self.distanceToStation \(self.distanceToStation)\n" +
        "self.shouldRun \(self.shouldRun)\n"
    }
    
    func toDictionary() -> Dictionary <String, AnyObject> {
        let depTime = self.departureTime != nil ? Int(Int(self.departureTime! - NSDate.timeIntervalSinceReferenceDate()) / 60) : 0
        let dict: [String: AnyObject] = [
            "originStationName": self.originStationName,
            "lineName": self.lineName,
            "eolStationName": self.eolStationName,
            "agency": self.agency,
            "departureTime": depTime,
            "lineCode": self.lineCode ?? "",
            "distanceToStation": self.distanceToStation ?? "",
            "shouldRun": self.shouldRun,
        ]
        return dict
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
        if (originsAreSame(thisRoute, routeB: routeA)) {
            return true
        } else {
            return collectorBool
        }
    })
}

func makeUniqRoutes(routes: [Route]) -> [Route] {
    var result = [Route]()
    for aRoute in routes {
        if !(routeInSet(result, routeA: aRoute)) {
            result.append(aRoute)
        }
    }
    return result
}
