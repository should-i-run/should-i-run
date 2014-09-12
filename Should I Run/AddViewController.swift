//
//  AddViewController.swift
//  should I run? draft
//
//  Created by Roger Goldfinger on 7/11/14.
//  Copyright (c) 2014 Roger Goldfinger. All rights reserved.
//

import UIKit

import MapKit

class AddViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, UISearchBarDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    

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

        self.searchBar.delegate = self;
        
        self.navigationController?.navigationBar.tintColor = globalTintColor
        self.view.backgroundColor = globalBackgroundColor
        self.navigationController?.navigationBar.barStyle = globalBarStyle


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
    
    func geocodeAddress(sender: AnyObject) {

        self.searchBar.resignFirstResponder()
        var currentRegion = CLCircularRegion(circularRegionWithCenter: self.locationManager.currentLocation2d!, radius: 1000.0, identifier: nil)
        geocoder.geocodeAddressString(searchBar.text, inRegion: currentRegion, completionHandler:{
            (response: Array?, error: NSError!) -> Void in

            var marker:MKPointAnnotation = MKPointAnnotation()

            if let res = response? {
                //get the location for the address and save it
                var resultsLocation = (res[0] as CLPlacemark).location
                self.lat = Float(resultsLocation.coordinate.latitude)
                self.lng = Float(resultsLocation.coordinate.longitude)
                
                //set the map view to show the current location and this address
                var distanceBetweenPoints = resultsLocation.distanceFromLocation(self.locationManager.currentLocation)

                let mapCenterlatitude = (resultsLocation.coordinate.latitude + self.locationManager.currentLocation2d!.latitude)/2
                let mapCenterlongitude = (resultsLocation.coordinate.longitude + self.locationManager.currentLocation2d!.longitude)/2
                let center = CLLocationCoordinate2D(latitude: mapCenterlatitude, longitude: mapCenterlongitude)
                let region = MKCoordinateRegionMakeWithDistance(center, distanceBetweenPoints + 1000, distanceBetweenPoints + 1000)

                self.mapView?.setRegion(self.mapView!.regionThatFits(region), animated: true)

                marker.coordinate = (res[0] as CLPlacemark).location.coordinate
                self.mapView!.removeAnnotations(self.mapView!.annotations)
                self.mapView!.addAnnotation(marker)
                self.currentAnnotation = marker

            }else{
                let geocodeAlertView = UIAlertView(title: "Error", message: "We couldnt find the specified address", delegate: nil, cancelButtonTitle: "Ok")
                geocodeAlertView.show()

            }
        })
    }

    @IBAction func tapOnMap(sender: UIGestureRecognizer) {
        self.searchBar.resignFirstResponder()

        var tapLocation: CGPoint = sender.locationInView(self.mapView)
        var geographicLocaction = self.mapView!.convertPoint(tapLocation, toCoordinateFromView: self.mapView)
        self.lat = Float(geographicLocaction.latitude)
        self.lng = Float(geographicLocaction.longitude)

        var location2d: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: geographicLocaction.latitude, longitude: geographicLocaction.longitude)

        let touchCLLLocation = CLLocation(latitude: geographicLocaction.latitude, longitude: geographicLocaction.longitude)


        geocoder.reverseGeocodeLocation(touchCLLLocation, completionHandler: {
            (response: [AnyObject]!, error: NSError!) -> Void in
                if(response.count > 0){
                    
                    var text = response[0].locality
                

                    if response[0].thoroughfare? != nil   {
                        text = "\(response[0].thoroughfare), " + text
                    }
                    if response[0].subThoroughfare? != nil  {
                        text = "\(response[0].subThoroughfare) " + text
                    }
                    self.searchBar.text = text
                }
            })

        if let mk = self.currentAnnotation {
            self.mapView!.removeAnnotation(self.currentAnnotation)
        }

        var marker:MKPointAnnotation = MKPointAnnotation()
        marker.coordinate = location2d
        self.mapView!.addAnnotation(marker)
        self.currentAnnotation = marker
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (sender as? UIBarButtonItem != self.saveBarButton) {
            return true
        }
        if self.lng == 0.00 {
            var message: UIAlertView = UIAlertView(title: "Location", message: "Please pick a location", delegate: nil, cancelButtonTitle: "Ok")
            message.show()
            return false
        }
        if self.searchBar.text == "" {
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

    func alertView(alertView: UIAlertView!, didDismissWithButtonIndex buttonIndex: Int) {
        if(buttonIndex == 1){
            self.performSegueWithIdentifier("backToMain", sender: "saveButton")
        }
    }

    @IBAction func presentAlertAndSave(sender: AnyObject) {

        self.destinationNameAlertView = UIAlertView(title: "Destination name", message: "Please choose a desination name", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Done")

        self.destinationNameAlertView!.alertViewStyle = UIAlertViewStyle.PlainTextInput
        
        self.destinationNameAlertView?.textFieldAtIndex(0)?.delegate = self

        self.destinationNameAlertView!.show()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.geocodeAddress(searchBar)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(self.destinationNameAlertView?.textFieldAtIndex(0)?.text.utf16Count < 1){
            return false
        }
        
        self.destinationNameAlertView?.dismissWithClickedButtonIndex(1, animated: true)
        
        return true
        
    }



    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        //loc is locations plist as an array
        
        if(sender is String){
            // Dispatch the saving asynchronous and to another queue to prevent blocking the interface
            let queue = dispatch_queue_create("saving", nil)
            dispatch_async(queue, { () -> Void in
                if let name = self.destinationNameAlertView?.textFieldAtIndex(0)?.text {
                    var savedLocations = self.fileManager.readFromDestinationsList()
                    
                    savedLocations.setObject(["name": name, "latitude": self.lat, "longitude": self.lng], atIndexedSubscript: savedLocations.count)
                    self.fileManager.saveToDestinationsList(savedLocations)
                    
                }
            })
            
        }
        
    }
    
    
}
