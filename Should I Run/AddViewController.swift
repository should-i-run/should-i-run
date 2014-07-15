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


    @IBOutlet var saveBarButton: UIBarButtonItem
    
    
    @IBOutlet var mapView: MKMapView
    
    var locationManager = CLLocationManager()


    var place:Place? = nil
    
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
    
        if (sender as? UIBarButtonItem != self.saveBarButton) {
            return
        }

        self.place = Place(name: self.textField.text, latitude: 35.0, longitude: -120.0)
        
                        let userDefaults = NSUserDefaults.standardUserDefaults()
                        var number : Int = userDefaults.integerForKey("num")
                        number = number+1
                        println(number)
                        userDefaults.setObject(["name": self.textField.text, "latitude": 35.9, "longitude": 6.40], forKey: String(number))
        
                        userDefaults.setInteger(number,forKey: "num")
                        userDefaults.synchronize()
        
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
        self.locationManager.startUpdatingLocation()

    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {

        //convert the user's location to a 2d coordinate
        let loc2d: CLLocationCoordinate2D =  locationManager.location.coordinate
        
        //create a 'region' with the user's location as the center, and set the map to that region
        let reg = MKCoordinateRegionMakeWithDistance(loc2d, 20000, 20000)
        self.mapView.setRegion(reg, animated: false)

        
    }
    
    //    - (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
    //    {
    //    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    //    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    //    }
    

//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
    


}
