//
//  AddViewController.swift
//  should I run? draft
//
//  Created by Roger Goldfinger on 7/11/14.
//  Copyright (c) 2014 Roger Goldfinger. All rights reserved.
//

import UIKit

import MapKit

class AddViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var lat: Float = 0.00
    var lng: Float = 0.00
    var destinationName: String?
    
    var alertController: UIAlertController?
    var doneAction: UIAlertAction?

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
        let currentRegion = CLCircularRegion(center: self.locationManager.currentLocation2d!, radius: 1000.0, identifier: "tap")
        geocoder.geocodeAddressString(searchBar.text!, inRegion: currentRegion, completionHandler:{
            (response: [CLPlacemark]?, error: NSError?) -> Void in

            let marker:MKPointAnnotation = MKPointAnnotation()

            if let res = response {
                //get the location for the address and save it
                let resultsLocation = (res[0] as CLPlacemark).location
                self.lat = Float(resultsLocation!.coordinate.latitude)
                self.lng = Float(resultsLocation!.coordinate.longitude)
                
                //set the map view to show the current location and this address
                let distanceBetweenPoints = resultsLocation!.distanceFromLocation(self.locationManager.currentLocation!)

                let mapCenterlatitude = (resultsLocation!.coordinate.latitude + self.locationManager.currentLocation2d!.latitude)/2
                let mapCenterlongitude = (resultsLocation!.coordinate.longitude + self.locationManager.currentLocation2d!.longitude)/2
                let center = CLLocationCoordinate2D(latitude: mapCenterlatitude, longitude: mapCenterlongitude)
                let region = MKCoordinateRegionMakeWithDistance(center, distanceBetweenPoints + 1000, distanceBetweenPoints + 1000)

                self.mapView?.setRegion(self.mapView!.regionThatFits(region), animated: true)

                marker.coordinate = (res[0] as CLPlacemark).location!.coordinate
                self.mapView!.removeAnnotations(self.mapView!.annotations)
                self.mapView!.addAnnotation(marker)
                self.currentAnnotation = marker

            } else {
                let geocodeAlertView = UIAlertView(title: "Error", message: "We couldnt find the specified address", delegate: nil, cancelButtonTitle: "Ok")
                geocodeAlertView.show()
            }
        })
    }

    @IBAction func tapOnMap(sender: UIGestureRecognizer) {
        self.searchBar.resignFirstResponder()

        let tapLocation: CGPoint = sender.locationInView(self.mapView)
        let geographicLocaction = self.mapView!.convertPoint(tapLocation, toCoordinateFromView: self.mapView)
        self.lat = Float(geographicLocaction.latitude)
        self.lng = Float(geographicLocaction.longitude)

        let location2d: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: geographicLocaction.latitude, longitude: geographicLocaction.longitude)

        let touchCLLLocation = CLLocation(latitude: geographicLocaction.latitude, longitude: geographicLocaction.longitude)
        geocoder.reverseGeocodeLocation(touchCLLLocation, completionHandler: {
            (response: [CLPlacemark]?, error: NSError?) -> Void in
            if let resp = response {
                if(resp.count > 0){
                    var text = resp[0].locality!
                    
                    if let tfare = resp[0].thoroughfare  {
                        text = "\(tfare), " + text
                    }
                    if let subtfare = resp[0].subThoroughfare  {
                        text = "\(subtfare) " + text
                    }
                    self.searchBar.text = text
                }
            }
        })

        if let mk = self.currentAnnotation {
            self.mapView!.removeAnnotation(mk)
        }

        let marker:MKPointAnnotation = MKPointAnnotation()
        marker.coordinate = location2d
        self.mapView!.addAnnotation(marker)
        self.currentAnnotation = marker
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (sender as? UIBarButtonItem != self.saveBarButton) {
            return true
        }
        if self.lng == 0.00 {
            let message: UIAlertView = UIAlertView(title: "Location", message: "Please pick a location", delegate: nil, cancelButtonTitle: "Ok")
            message.show()
            return false
        }
        if self.searchBar.text == "" {
            let message: UIAlertView = UIAlertView(title: "Location", message: "Please add a destination", delegate: nil, cancelButtonTitle: "Ok")
            message.show()
            return false
        }
        return true
    }

    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        for annView in views
        {
            let endFrame: CGRect  = annView.frame;
            (annView as MKAnnotationView).frame = CGRectOffset(endFrame, 0, -500);
            
            UIView.animateWithDuration(0.2, animations: {
                    (annView as MKAnnotationView).frame = endFrame;
                })
        }
    }
    
    func onTextFieldChange(textField: UITextField) {
        if self.alertController!.textFields?.first?.text?.isEmpty != true {
            self.doneAction?.enabled = true
        } else {
            self.doneAction?.enabled = false
        }
    }

    @IBAction func presentAlertAndSave(sender: AnyObject) {
        
        self.alertController = UIAlertController(title: "Destination name", message: "Please choose a destination name", preferredStyle: UIAlertControllerStyle.Alert)
        
        self.doneAction = UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            let name = self.alertController?.textFields?.first?.text!
            self.destinationName = name
            self.performSegueWithIdentifier("backToMain", sender: "saveButton")
        })
        
        self.doneAction!.enabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        self.alertController!.addAction(self.doneAction!)
        self.alertController!.addAction(cancelAction)
        self.alertController!.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Enter a name"
            textField.addTarget(self, action: "onTextFieldChange:", forControlEvents: UIControlEvents.EditingChanged)
            textField.enablesReturnKeyAutomatically = true
        })
        
        self.presentViewController(self.alertController!, animated: true, completion: nil)

    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.geocodeAddress(searchBar)
    }

    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if(sender is String){
            if let name = self.destinationName {
                let savedLocations = self.fileManager.readFromDestinationsList()
                savedLocations.insertObject(["name": name, "latitude": self.lat, "longitude": self.lng], atIndex: savedLocations.count)
                self.fileManager.saveToDestinationsList(savedLocations)
            }
        }
    }
}
