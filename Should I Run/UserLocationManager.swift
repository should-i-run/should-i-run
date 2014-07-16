//
//  UserLocationManager.swift
//  Should I Run
//
//  Created by Roger Goldfinger on 7/16/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//


// how to use:
// call SharedUserLocation.currentLocation2d from any class


import MapKit


class UserLocation: NSObject, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    
    //you can access the lat and long by calling:
      // currentLocation2d.latitude, etc
    //
    var currentLocation2d:CLLocationCoordinate2D?

    
    class var manager: UserLocation {
        return SharedUserLocation
    }
    
    init () {
        super.init()
        if self.locationManager.respondsToSelector(Selector("requestAlwaysAuthorization")) {
            self.locationManager.requestWhenInUseAuthorization()
        }
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 50
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        self.currentLocation2d = manager.location.coordinate
        
    }
    
    
    

}

let SharedUserLocation = UserLocation()


