//
//  UserLocationManager.swift
//  Should I Run
//
//  Created by Roger Goldfinger on 7/16/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//


// how to use:
// call SharedUserLocation.currentLocation2d from any class
// or, to receive updates
//    let locationManager = SharedUserLocation //in the class body
//        self.notificationCenter.addObserverForName("LocationDidUpdate", object: nil, queue: self.mainQueue) { _ in
//      let loc2d: CLLocationCoordinate2D =  self.locationManager.currentLocation2d!
//      //now you can use the location
//    }


import MapKit


class UserLocation: NSObject, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    
    //you can access the lat and long by calling:
      // currentLocation2d.latitude, etc
    //
    var currentLocation2d:CLLocationCoordinate2D?
    
    let notificationCenter:NSNotificationCenter = NSNotificationCenter.defaultCenter()
    let mainQueue:NSOperationQueue = NSOperationQueue.mainQueue()

    
    class var manager: UserLocation {
        return SharedUserLocation
    }
    
    init () {
        super.init()


        //ios 8 only
        if self.locationManager.respondsToSelector(Selector("requestAlwaysAuthorization")) {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.distanceFilter = 50
        self.locationManager.startUpdatingLocation()


        
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {


        self.currentLocation2d = manager.location.coordinate


        self.notificationCenter.postNotificationName("LocationDidUpdate", object: nil)
        
        
    }
    
    
    

}

let SharedUserLocation = UserLocation()


