//
//  LoadingViewController.swift
//  Should I Run
//
//  Created by Roger Goldfinger on 7/17/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import UIKit
import MapKit


enum NetworkStatusStruct: Int {
    case NotReachable = 0
    case ReachableViaWiFi
    case ReachableViaWWAN
}

class LoadingViewController: UIViewController, BartApiControllerDelegate, GoogleAPIControllerProtocol, CLLocationManagerDelegate, UIAlertViewDelegate, MuniAPIControllerDelegate {
    
    var viewHasAlreadyAppeared = false
    
    
    var locationName:String?
    var destinationLatitude : Float?
    var destinationLongitude : Float?
    
    //37.786059, -122.405156
    var startLatitude:Float = 37.786059
    var startLongitude:Float = -122.405156
    
    @IBOutlet var spinner: UIActivityIndicatorView?
    
    var bartResults: [(String, Int)]?
    var googleResults : [String]?
    var muniResults: [(departureTime: Int, distanceToStation: String, originStationName: String, lineName: String, eolStationName: String)]?
    
    var distanceToStart : Int = 0
    var departureStationName: String = ""
    
    let notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()
    let mainQueue: NSOperationQueue = NSOperationQueue.mainQueue()
    let locationManager = SharedUserLocation
    
    // Create controller to handle BART API queries
    var bartApiHandler = BartApiController()
    var muniApiHandler = MuniApiController()
    
    //Create controller to handle Google API queries
    var googleApiHandler : GoogleApiController = GoogleApiController()
    
    var internetReachability: Reachability = Reachability.reachabilityForInternetConnection()
    
    // Create a timer to segue back on a hard timelimit
    var timeoutTimer: NSTimer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start spinner animation
        spinner!.startAnimating()
        
        // Set background color
        self.view.backgroundColor = globalBackgroundColor
        
        //get the internet going
        self.internetReachability.connectionRequired()
        self.internetReachability.startNotifier()
        
    }
    
    
    
    override func viewDidAppear(animated: Bool){
        
        if !self.viewHasAlreadyAppeared {
            
            self.viewHasAlreadyAppeared = true
            
            var networkStatus  = self.internetReachability.currentReachabilityStatus()
            
            if (!self.locationManager.hasLocation) {
                var message: UIAlertView = UIAlertView(title: "Sorry!", message: "We couldn't find your location.", delegate: self, cancelButtonTitle: "Ok")
                message.show()
            }
            
            // Set timer to segue back (by calling segueFromView) back to the main table view
            var timeoutText: Dictionary = ["titleString": "Time Out","messageString": "Sorry! Your request took too long."]
            self.timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("timerTimeut:"), userInfo: timeoutText, repeats: false)
            
            
            //set this class as the delegate for the api controllers
            self.googleApiHandler.delegate = self
            self.bartApiHandler.delegate = self
            self.muniApiHandler.delegate = self
            
            
            //Fetching data from Google and parsing it
            if(networkStatus == NOT_REACHABLE ){
                self.navigationController.popViewControllerAnimated(true)
            }else{
                if let loc2d: CLLocationCoordinate2D =  self.locationManager.currentLocation2d {
                    
                    self.startLatitude = Float(loc2d.latitude)
                    self.startLongitude = Float(loc2d.longitude)
                    self.googleApiHandler.fetchGoogleData(self.locationName!, latDest: self.destinationLatitude!,lngDest: self.destinationLongitude!,latStart: self.startLatitude,lngStart: self.startLongitude)
                    
                } else {
                    
                    self.notificationCenter.addObserverForName("LocationDidUpdate", object: nil, queue: self.mainQueue) { _ in
                        
                        if let loc2d: CLLocationCoordinate2D =  self.locationManager.currentLocation2d {
                            
                            self.startLatitude = Float(loc2d.latitude)
                            self.startLongitude = Float(loc2d.longitude)
                            self.googleApiHandler.fetchGoogleData(self.locationName!, latDest:self.destinationLatitude!,lngDest: self.destinationLongitude!,latStart: self.startLatitude,lngStart: self.startLongitude)
                            self.locationManager.hasLocation = true
                        }
                    }
                }
            }
        }
    }
    
    func didReceiveGoogleResults(results: [String]) {
        
        self.distanceToStart = results[0].toInt()!
        self.departureStationName = results[1]
        self.googleResults = results
        self.bartApiHandler.searchBartFor(self.departureStationName)
        
    }
    
    func didReceiveGoogleResults(results: [(distanceToStation: String, muniOriginStationName: String, lineCode: String, lineName: String, eolStationName: String)], muni: Bool) {
        
        self.muniApiHandler.searchMuniFor(results)
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
    
    func didReceiveMuniResults(results: [(departureTime: Int, distanceToStation: String, originStationName: String, lineName: String, eolStationName: String)]) {
        
        self.muniResults = results
        self.performSegueWithIdentifier("ResultsSegue", sender: self)
    }
    
    
    
    // Error handling-----------------------------------------------------
    
    
    // This function gets called when the user clicks on the alertView button to dismiss it (see didReceiveGoogleResults)
    // It performs the unwind segue when done.
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int) {
        timeoutTimer.invalidate()
        self.performSegueWithIdentifier("ErrorUnwindSegue", sender: self)
    }
    
    func handleError(errorMessage: String) {
        self.googleApiHandler.cancelConnection()
        self.bartApiHandler.cancelConnection()
        self.muniApiHandler.cancelConnection()
        // Create and show error message
        // delegates to the alertView function above when 'Ok' is clicked and then perform unwind segue to previous screen.
        var message: UIAlertView = UIAlertView(title: "Oops!", message: errorMessage, delegate: self, cancelButtonTitle: "Ok")
        message.show()
        
    }
    
    // Timeouts redirect here.
    func timerTimeout(timer: NSTimer) {
        handleError("Request timed out")
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!)  {
        
        // On segue, stop animating
        spinner!.stopAnimating()
        
        // Invalidate the timeout timer when we leave the view
        timeoutTimer.invalidate()
        
        if segue.identifier == "ResultsSegue" {
            var destinationController = segue.destinationViewController as ResultViewController
            
            //if we have muni data, pass it in
            if let muniData = self.muniResults {
                destinationController.muniResults = muniData
                //stuff as appropriate
                
                //otherwise assuming we have bart
            } else {
                
                destinationController.distanceToOrigin = self.distanceToStart
                destinationController.departureStationName = bartLookupReverse[self.departureStationName.lowercaseString]!
                destinationController.departures = self.bartResults!
            }
        } else if segue.identifier == "ErrorUnwindSegue" {
            
        }
    }
}

