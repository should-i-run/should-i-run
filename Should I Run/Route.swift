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
    var departureTime: Int?
    var distanceToStation: Int
    var originStationName: String
    var lineName: String
    var eolStationName: String
    var originLatLon:CLLocationCoordinate2D
    var agency: String
    
    init (distanceToStation: Int, originStationName: String, lineName: String, eolStationName: String, originCoord2d: CLLocationCoordinate2D, agency: String, departureTime: Int?) {
        
        self.distanceToStation = distanceToStation
        self.originStationName = originStationName
        self.lineName = lineName
        self.eolStationName = eolStationName
        self.agency = agency
        self.originLatLon = originCoord2d
        
        //initialise departure time, if it's around
        if let time = departureTime? {
            self.departureTime = time
        }
    }
    
}

//func didReceiveMuniResults(results: [(departureTime: Int, distanceToStation: String, originStationName: String, lineName: String, eolStationName: String, originLatLon:(lat:String, lon:String))])