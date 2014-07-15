//
//  Place.swift
//  should I run? draft
//
//  Created by Roger Goldfinger on 7/11/14.
//  Copyright (c) 2014 Roger Goldfinger. All rights reserved.
//

import UIKit

class Place {
    
    var placeName:String
    var lat: Double
    var lng: Double
    

    init(name: String, latitude: Double, longitude: Double) {
        self.placeName = name
        self.lat = latitude
        self.lng = longitude
        var numUses = 0
    }
   
}
