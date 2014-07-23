//
//  LoadingViewController.swift
//  Should I Run
//
//  Created by Roger Goldfinger on 7/17/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import UIKit
import MapKit

class LoadingViewController: UIViewController, BartApiControllerDelegate, GoogleAPIControllerProtocol, CLLocationManagerDelegate, UIAlertViewDelegate {
    
    var locationName:String?
    var destinationLatitude : Float?
    var destinationLongitude : Float?
    
    //37.786059, -122.405156
    var startLatitude:Float = 37.786059
    var startLongitude:Float = -122.405156
    
    @IBOutlet var spinner: UIActivityIndicatorView?
    
    var bartResults: [(String, Int)]?
    var googleResults : [String]?
    
    var distanceToStart : Int = 0
    var departureStationName: String = ""
    
    let notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()
    let mainQueue: NSOperationQueue = NSOperationQueue.mainQueue()
    let locationManager = SharedUserLocation
    
    // Create controller to handle BART API queries
    var bartApiHandler: BartApiController = BartApiController()
    
    //Create controller to handle Google API queries
    var googleApiHandler : GoogleApiController = GoogleApiController()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        // Start spinner animation
        spinner!.startAnimating()
        
        // Set background color
        self.view.backgroundColor = globalBackgroundColor

        //set this class as the delegate for the api controllers
        self.googleApiHandler.delegate = self
        self.bartApiHandler.delegate = self
        
        //Fetching data from Google and parsing it
        if let loc2d: CLLocationCoordinate2D =  self.locationManager.currentLocation2d {
            
            self.startLatitude = Float(loc2d.latitude)
            self.startLongitude = Float(loc2d.longitude)
            self.googleApiHandler.fetchGoogleData(self.destinationLatitude!,lngDest: self.destinationLongitude!,latStart: self.startLatitude,lngStart: self.startLongitude)
            
        } else {
            
            self.notificationCenter.addObserverForName("LocationDidUpdate", object: nil, queue: self.mainQueue) { _ in
            
                if let loc2d: CLLocationCoordinate2D =  self.locationManager.currentLocation2d {
                    
                    self.startLatitude = Float(loc2d.latitude)
                    self.startLongitude = Float(loc2d.longitude)
                    self.googleApiHandler.fetchGoogleData(self.destinationLatitude!,lngDest: self.destinationLongitude!,latStart: self.startLatitude,lngStart: self.startLongitude)
                }
            }
        }


    }

    // This function gets called when the user clicks on the alertView button to dismiss it (see didReceiveGoogleResults)
    // It performs the unwind segue when done.
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int) {
        self.performSegueWithIdentifier("ErrorUnwindSegue", sender: self)
    }
    
    func didReceiveGoogleResults(results: Array<String>!, error: String?) {
        if let err = error? {
            println("google err, unwinding")
            
            // Create and show error message when no Google results are found. Delegate to itself on clickin 'Ok'.
            // Call the alertView function above when 'Ok' is clicked and then perform unwind segue to previous screen.
            var message: UIAlertView = UIAlertView(title: "Oops!", message: "No results found.", delegate: self, cancelButtonTitle: "Ok")
            message.show()

        } else {

            self.distanceToStart = results[0].toInt()!
            self.departureStationName = results[1]
            self.googleResults = results
            self.bartApiHandler.searchBartFor(self.departureStationName)
        }

        
    }
    
    // Conform to BartApiControllerProtocol by implementing this method
    func didReceiveBartResults(results: [(String, Int)]) {

        //filter bart results based on google's EOL stations
        var goog = self.googleResults!
        
        var filteredBartResults:[(String, Int)] = []
        
        for var i = 2; i < goog.count; ++i {
            var stationName = goog[i]
            for trip in results {
                if trip.0 == stationName {
                    filteredBartResults += trip
                }
            }
        }

        self.bartResults = filteredBartResults
        self.performSegueWithIdentifier("ResultsSegue", sender: self)
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!)  {
        
        // On segue, stop animating
        spinner!.stopAnimating()
    
        if segue.identifier == "ResultsSegue" {
            var destinationController = segue.destinationViewController as ResultViewController
            destinationController.distance = self.distanceToStart
            destinationController.departureStationName = self.departureStationName
            destinationController.departures = self.bartResults!
        } else if segue.identifier == "ErrorUnwindSegue" {

        }
    }
}

