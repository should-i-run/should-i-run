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
    
    var mapCenteredOnUser: Bool = false
    
    var currentAnnotation: MKPointAnnotation?
    

    
//    var locationManager = CLLocationManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let loc2d: CLLocationCoordinate2D =  SharedUserLocation.currentLocation2d {

            //create a 'region' with the user's location as the center, and set the map to that region
            let reg = MKCoordinateRegionMakeWithDistance(loc2d, 20000, 20000)
            self.mapView.setRegion(reg, animated: false)
            self.mapCenteredOnUser = true
        }

        
        
        
        //check required for iOS 8.
        //we see if the location manager has this request method.
        //If so we are on 8 and need to request auth
//        if self.locationManager.respondsToSelector(Selector("requestAlwaysAuthorization")) {
//            self.locationManager.requestWhenInUseAuthorization()
//        }
//        
//        
//        self.locationManager.delegate = self
//        
//        //We don't need to be very accurate here, since we're just centering the map
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//        self.locationManager.distanceFilter = 1000
//        self.locationManager.startUpdatingLocation()
 
        
    }
    
//    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
//        
//        //first check if the map has been centered yet. We don't want to keep recentering.
//        
//        if self.mapCenteredOnUser == false {
//            //convert the user's location to a 2d coordinate
//            let loc2d: CLLocationCoordinate2D =  locationManager.location.coordinate
//                
//            //create a 'region' with the user's location as the center, and set the map to that region
//            let reg = MKCoordinateRegionMakeWithDistance(loc2d, 20000, 20000)
//            self.mapView.setRegion(reg, animated: false)
//            self.mapCenteredOnUser = true
//        }
//        
//    }


    
    @IBAction func tapOnMap(sender: UITapGestureRecognizer) {

        var tapLocation: CGPoint = sender.locationInView(self.mapView)
        var loc = self.mapView.convertPoint(tapLocation, toCoordinateFromView: self.mapView)
        self.lat = Float(loc.latitude)
        self.lng = Float(loc.longitude)
        
        var location2d: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
        
        if let mk = self.currentAnnotation {
            self.mapView.removeAnnotation(self.currentAnnotation)
        }
        
        var marker:MKPointAnnotation = MKPointAnnotation()
        marker.coordinate = location2d
        self.mapView.addAnnotation(marker)
        self.currentAnnotation = marker
        
//        
//        marker.
//            coordinate(location2d)
    }
    
//    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
//        
//        
//        
//        var marker: MKAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "marker")
//        
//        marker.annotation = annotation
//        
//        return marker
//    }
    
    

    override func shouldPerformSegueWithIdentifier(identifier: String!, sender: AnyObject!) -> Bool {
        if (sender as? UIBarButtonItem != self.saveBarButton) {
            return true
        }
        if self.lng == 0.00 {
            var message: UIAlertView = UIAlertView(title: "Location", message: "Please pick a location", delegate: nil, cancelButtonTitle: "Ok")
            message.show()
            return false
        }
        if self.textField.text == "" {
            var message: UIAlertView = UIAlertView(title: "Location", message: "Please add a location name", delegate: nil, cancelButtonTitle: "Ok")
            message.show()
            return false
            
        }
        return true
        
        
    }



    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        
        if (sender as? UIBarButtonItem != self.saveBarButton) {
            return
        }
        

        let userDefaults = NSUserDefaults.standardUserDefaults()
        var number : Int = userDefaults.integerForKey("num")
        
        
        userDefaults.setObject(["name": self.textField.text, "latitude": self.lat, "longitude": self.lng], forKey: String(number))
        number += 1
  
        userDefaults.setInteger(number,forKey: "num")
        userDefaults.synchronize()
    }
    


 

//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
    


}
