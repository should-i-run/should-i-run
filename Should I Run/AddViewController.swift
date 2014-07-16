//
//  AddViewController.swift
//  should I run? draft
//
//  Created by Roger Goldfinger on 7/11/14.
//  Copyright (c) 2014 Roger Goldfinger. All rights reserved.
//

import UIKit

import MapKit

class AddViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {


    @IBOutlet var textField : UITextField
    
    var lat: Float = 0.00
    var lng: Float = 0.00


    @IBOutlet var saveBarButton: UIBarButtonItem
    
    
    @IBOutlet var mapView: MKMapView
    

    
    var locationManager = CLLocationManager()


    var place:Place? = nil
    
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
    
        if (sender as? UIBarButtonItem != self.saveBarButton) {
            return
        }
       
        var thisLat = self.lat

        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var number : Int = userDefaults.integerForKey("num")
        number = number+1

        userDefaults.setObject(["name": self.textField.text, "latitude": self.lat, "longitude": self.lng], forKey: String(number))

        userDefaults.setInteger(number,forKey: "num")
        userDefaults.synchronize()
        
    }
    
    @IBAction func tapOnMap(gestureRecognizer: UIGestureRecognizer) {
        var tapLocation: CGPoint = gestureRecognizer.locationInView(self.mapView)
        var loc = self.mapView.convertPoint(tapLocation, toCoordinateFromView: self.mapView)
        self.lat = Float(loc.latitude)
        self.lng = Float(loc.longitude)
        
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //check required for iOS 8.
        //we see if the location manager has this request method. 
        //If so we are on 8 and need to request auth
        if self.locationManager.respondsToSelector(Selector("requestAlwaysAuthorization")) {
                    self.locationManager.requestWhenInUseAuthorization()
        }
        
        
        self.locationManager.delegate = self
        
        //We don't need to be very accurate here, since we're just centering the map
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        //convert the user's location to a 2d coordinate
        let loc2d: CLLocationCoordinate2D =  locationManager.location.coordinate
        
        //create a 'region' with the user's location as the center, and set the map to that region
        let reg = MKCoordinateRegionMakeWithDistance(loc2d, 20000, 20000)
        self.mapView.setRegion(reg, animated: false)


    }


//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
    


}
