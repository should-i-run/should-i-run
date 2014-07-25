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


    @IBOutlet var textField : UITextField?
    
    var lat: Float = 0.00
    var lng: Float = 0.00


    @IBOutlet var saveBarButton: UIBarButtonItem?
    
    
    @IBOutlet var mapView: MKMapView?
    
    var mapCenteredOnUser: Bool = false
    
    var currentAnnotation: MKPointAnnotation?
    
    let notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()
    let mainQueue: NSOperationQueue = NSOperationQueue.mainQueue()

    
    let locationManager = SharedUserLocation
    let fileManager = SharedFileManager
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation and background colors
//        self.navigationController.navigationBar.barTintColor = globalNavigationBarColor
        self.navigationController.navigationBar.tintColor = globalTintColor
        self.view.backgroundColor = globalBackgroundColor
        self.navigationController.navigationBar.barStyle = globalBarStyle

        
        if let loc2d: CLLocationCoordinate2D =  self.locationManager.currentLocation2d {
            let reg = MKCoordinateRegionMakeWithDistance(loc2d, 20000, 20000)
            self.mapView!.setRegion(reg, animated: false)
            self.mapCenteredOnUser = true
            
        } else {
        
            self.notificationCenter.addObserverForName("LocationDidUpdate", object: nil, queue: self.mainQueue) { _ in
                
                let updatedLoc2d: CLLocationCoordinate2D =  self.locationManager.currentLocation2d!
                
                //create a 'region' with the user's location as the center, and set the map to that region
                let reg = MKCoordinateRegionMakeWithDistance(updatedLoc2d, 20000, 20000)
                self.mapView!.setRegion(reg, animated: false)
                self.mapCenteredOnUser = true
            }
        }
        
        
    }
    
    @IBAction func tapOnMap(sender: UITapGestureRecognizer) {

        var tapLocation: CGPoint = sender.locationInView(self.mapView)
        var loc = self.mapView!.convertPoint(tapLocation, toCoordinateFromView: self.mapView)
        self.lat = Float(loc.latitude)
        self.lng = Float(loc.longitude)
        
        var location2d: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
        
        if let mk = self.currentAnnotation {
            self.mapView!.removeAnnotation(self.currentAnnotation)
        }
        
        var marker:MKPointAnnotation = MKPointAnnotation()
        marker.coordinate = location2d
        self.mapView!.addAnnotation(marker)
        self.currentAnnotation = marker
    }

    override func shouldPerformSegueWithIdentifier(identifier: String!, sender: AnyObject!) -> Bool {
        if (sender as? UIBarButtonItem != self.saveBarButton) {
            return true
        }
        if self.lng == 0.00 {
            var message: UIAlertView = UIAlertView(title: "Location", message: "Please pick a location", delegate: nil, cancelButtonTitle: "Ok")
            message.show()
            return false
        }
        if self.textField!.text == "" {
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
        //loc is locations plist as an array
        
        var savedLocations = self.fileManager.readFromDestinationsList()
       
        savedLocations.setObject(["name": self.textField!.text, "latitude": self.lat, "longitude": self.lng], atIndexedSubscript: savedLocations.count)
        
        self.fileManager.saveToDestinationsList(savedLocations)
        
    }


}
