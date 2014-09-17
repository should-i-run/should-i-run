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

class LoadingViewController: UIViewController, BartApiControllerDelegate, GoogleAPIControllerProtocol, ParseGoogleHelperDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, MuniAPIControllerDelegate {
    
    var viewHasAlreadyAppeared = false
    var locationObserver:AnyObject?
    
    var backgroundColor = UIColor()
    
    
    
    var locationName = String()
    var destinationLatitude = Float()
    var destinationLongitude = Float()
    
    
    var startLatitude = Float()
    var startLongitude = Float()
    var resultsRoutes = [Route]()
    
    @IBOutlet var spinner: UIActivityIndicatorView?
    

    
    let notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()
    let mainQueue: NSOperationQueue = NSOperationQueue.mainQueue()
    let locationManager = SharedUserLocation
    
    // Create controller to handle BART API queries
    var bartApiHandler = BartApiController()
    var muniApiHandler = MuniApiController()
    
    //Create controller to handle Google API queries
    var googleApiHandler : GoogleApiController = GoogleApiController()
    var parseGoogleHelper:ParseGoogleHelper = ParseGoogleHelper()
    
    var internetReachability: Reachability = Reachability.reachabilityForInternetConnection()
    
    // Create a timer to segue back on a hard timelimit
    var timeoutTimer: NSTimer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start spinner animation
        spinner!.startAnimating()
        
        // Set background color
        self.view.backgroundColor = self.backgroundColor
        
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
            self.timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: Selector("timerTimeout:"), userInfo: timeoutText, repeats: false)
            
            
            //set this class as the delegate for the api controllers
            self.googleApiHandler.delegate = self
            self.bartApiHandler.delegate = self
            self.muniApiHandler.delegate = self
            self.parseGoogleHelper.delegate = self
            
            
            //Fetching data from Google and parsing it
            if(networkStatus == NOT_REACHABLE ){
                self.navigationController?.popViewControllerAnimated(true)
            }else{
                if let loc2d: CLLocationCoordinate2D =  self.locationManager.currentLocation2d {
                    
                    self.startLatitude = Float(loc2d.latitude)
                    self.startLongitude = Float(loc2d.longitude)
                    self.googleApiHandler.fetchGoogleData(self.locationName, latDest: self.destinationLatitude, lngDest: self.destinationLongitude,latStart: self.startLatitude,lngStart: self.startLongitude)
                    
                } else {
                    
                    self.locationObserver = self.notificationCenter.addObserverForName("LocationDidUpdate", object: nil, queue: self.mainQueue) { _ in
                        
                        if let loc2d: CLLocationCoordinate2D =  self.locationManager.currentLocation2d {
                            
                            self.startLatitude = Float(loc2d.latitude)
                            self.startLongitude = Float(loc2d.longitude)
                            self.googleApiHandler.fetchGoogleData(self.locationName, latDest:self.destinationLatitude,lngDest: self.destinationLongitude,latStart: self.startLatitude,lngStart: self.startLongitude)
                            self.locationManager.hasLocation = true
                        }
                    }
                }
            }
        }
    }
    
    func didReceiveGoogleData(data: NSDictionary)  {
        
        self.parseGoogleHelper.parser(data)
        
        
    }
    
    func didReceiveGoogleResults(results: [Route]) {
        // we can assume that the routes coming in are uniq
        // we want to get all possible departure times for each route - different EOL stations
        // But we only want to do one api request for each origin station
        
        // TODO: make this handle both bart and muni in same set of results
        // as well as different origin stations
        // we will also need to keep track of the requests made, and not transition until they all come back-- allowing for errors
        
        var bartResults = [Route]()
        var muniResults = [Route]()

        
    
        if results[0].agency == "bart" {
            self.bartApiHandler.searchBartFor(results)
        } else if results[0].agency == "muni" {
            self.muniApiHandler.searchMuniFor(results)
        } else if results[0].agency == "caltrain" {
            self.resultsRoutes = results
            self.performSegueWithIdentifier("ResultsSegue", sender: self)
        }
        

    }
    

    
    
    // Conform to BartApiControllerProtocol by implementing this method
    func didReceiveBartResults(results: [Route]) {
        
        self.resultsRoutes = results
        self.performSegueWithIdentifier("ResultsSegue", sender: self)
    }
    
    func didReceiveMuniResults(results: [Route]) {
        
        self.resultsRoutes = results
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
        self.timeoutTimer.invalidate()
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
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)  {
        
        if self.locationObserver != nil {
            self.notificationCenter.removeObserver(self.locationObserver!)
        }
        
        // On segue, stop animating
        spinner!.stopAnimating()
        
        // Invalidate the timeout timer when we leave the view
        timeoutTimer.invalidate()
        
        if segue.identifier == "ResultsSegue" {
            var destinationController = segue.destinationViewController as ResultViewController
            
            destinationController.resultsRoutes = self.resultsRoutes
        } else if segue.identifier == "ErrorUnwindSegue" {
            
        }
    }
}

