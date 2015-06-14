//
//  Destination.swift
//  ShouldIRun
//
//  Created by Roger Goldfinger on 6/14/15.
//  Copyright (c) 2015 Should I Run. All rights reserved.
//

import Foundation
import MapKit

class Destination {
    let location: CLLocationCoordinate2D
    let name: String
    let color: UIColor
    
    init(name: String, lat: Float, lon: Float, color: UIColor) {
        
        let locationCoord:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))
        self.location = locationCoord
        self.color = color
        self.name = name
    }
}