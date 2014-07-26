//
//  AddViewController.swift
//  should I run? draft
//
//  Created by Roger Goldfinger on 7/11/14.
//  Copyright (c) 2014 Roger Goldfinger. All rights reserved.
//

import UIKit

import MapKit

class AddViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, UITextFieldDelegate {

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

    var destinationNameAlertView:UIAlertView?

    let geocoder = CLGeocoder()

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

    @IBAction func geocodeAddress(sender: AnyObject) {

        self.textField?.resignFirstResponder()
        var currentRegion = CLCircularRegion(circularRegionWithCenter: self.locationManager.currentLocation2d!, radius: 1000.0, identifier: nil)
        geocoder.geocodeAddressString(textField?.text, inRegion: currentRegion, completionHandler:{
            (response: Array!, error: NSError!) -> Void in

            var marker:MKPointAnnotation = MKPointAnnotation()

            if (response.count > 0) {
                var resultsLocation = (response[0] as CLPlacemark).location
                var distanceBetweenPoints = resultsLocation.distanceFromLocation(self.locationManager.currentLocation)

                let mapCenterlatitude = (resultsLocation.coordinate.latitude + self.locationManager.currentLocation2d!.latitude)/2
                let mapCenterlongitude = (resultsLocation.coordinate.longitude + self.locationManager.currentLocation2d!.longitude)/2
                let center = CLLocationCoordinate2D(latitude: mapCenterlatitude, longitude: mapCenterlongitude)
                let region = MKCoordinateRegionMakeWithDistance(center, distanceBetweenPoints + 1000, distanceBetweenPoints + 1000)

                self.mapView?.setRegion(self.mapView!.regionThatFits(region), animated: true)

                marker.coordinate = (response[0] as CLPlacemark).location.coordinate
                self.mapView!.removeAnnotations(self.mapView!.annotations)
                self.mapView!.addAnnotation(marker)
                self.currentAnnotation = marker
            }else{
                let geocodeAlertView = UIAlertView(title: "Error", message: "We couldnt find the specified address", delegate: nil, cancelButtonTitle: "Ok")
                geocodeAlertView.show()

            }

        })

        //        geocoder.geocodeAddressString(textField?.text, completionHandler:{
        //            (response: [AnyObject]!,error: NSError!) -> Void in
        //                println(response)
        //            })

    }

    @IBAction func tapOnMap(sender: UIGestureRecognizer) {


        var tapLocation: CGPoint = sender.locationInView(self.mapView)
        var geographicLocaction = self.mapView!.convertPoint(tapLocation, toCoordinateFromView: self.mapView)
        self.lat = Float(geographicLocaction.latitude)
        self.lng = Float(geographicLocaction.longitude)

        var location2d: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: geographicLocaction.latitude, longitude: geographicLocaction.longitude)

        let touchCLLLocation = CLLocation(latitude: geographicLocaction.latitude, longitude: geographicLocaction.longitude)


        geocoder.reverseGeocodeLocation(touchCLLLocation, completionHandler: {
            (response: [AnyObject]!, error: NSError!) -> Void in
                self.textField!.text = "\(response[0].name), \(response[0].locality)"
            })

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
            var message: UIAlertView = UIAlertView(title: "Location", message: "Please add a destination", delegate: nil, cancelButtonTitle: "Ok")
            message.show()
            return false

        }

        return true
    }

    func mapView(mapView: MKMapView!, didAddAnnotationViews views: [AnyObject]!) {
        for annView in views
        {
            var endFrame: CGRect  = annView.frame;
            (annView as MKAnnotationView).frame = CGRectOffset(endFrame, 0, -500);
            
            UIView.animateWithDuration(0.2, animations: {
                    (annView as MKAnnotationView).frame = endFrame;
                })
        }
    }

    func alertView(alertView: UIAlertView!, willDismissWithButtonIndex buttonIndex: Int) {
        if(buttonIndex == 1){
            self.performSegueWithIdentifier("backToMain", sender: self)
        }
    }

    @IBAction func presentAlertAndSave(sender: AnyObject) {

        self.destinationNameAlertView = UIAlertView(title: "Destination name", message: "Please choose a desination name", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Done")

        self.destinationNameAlertView!.alertViewStyle = UIAlertViewStyle.PlainTextInput

        self.destinationNameAlertView!.textFieldAtIndex(0).delegate = self

        self.destinationNameAlertView!.show()
        //self.performSegueWithIdentifier("backToMain", sender: sender)
    }

    func textFieldShouldReturn(textField: UITextField!) -> Bool {

        destinationNameAlertView!.dismissWithClickedButtonIndex(1, animated: true)

        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {

//        if (sender as? UIBarButtonItem != self.saveBarButton) {
//            return
//        }
        //loc is locations plist as an array

        var savedLocations = self.fileManager.readFromDestinationsList()
        
        savedLocations.setObject(["name": self.destinationNameAlertView!.textFieldAtIndex(0).text, "latitude": self.lat, "longitude": self.lng], atIndexedSubscript: savedLocations.count)
        
        self.fileManager.saveToDestinationsList(savedLocations)
        
    }
    
    
}
