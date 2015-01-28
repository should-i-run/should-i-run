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

class LoadingViewController: UIViewController, ApiControllerProtocol, CLLocationManagerDelegate, UIAlertViewDelegate, WalkingDirectionsDelegate {
    
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
    var walkingDirectionsManager = SharedWalkingDirectionsManager
    var walkingRequestsCount = 0
    
    
    var apiHandler = apiController()
    
    var internetReachability: Reachability = Reachability.reachabilityForInternetConnection()
    
    // Create a timer to segue back on a hard timelimit
    var timeoutTimer: NSTimer = NSTimer()
    
    override func viewDidLoad() {
        self.walkingDirectionsManager.delegate = self
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
            self.apiHandler.delegate = self
            
            self.viewHasAlreadyAppeared = true
            
            var networkStatus  = self.internetReachability.currentReachabilityStatus()
            
            if (!self.locationManager.hasLocation) {
                var message: UIAlertView = UIAlertView(title: "Sorry!", message: "We couldn't find your location.", delegate: self, cancelButtonTitle: "Ok")
                message.show()
            }
            
            // Set timer to segue back (by calling segueFromView) back to the main table view
            var timeoutText: Dictionary = ["titleString": "Time Out","messageString": "Sorry! Your request took too long."]
            self.timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: Selector("timerTimeout:"), userInfo: timeoutText, repeats: false)
            
            //Fetching data from Google and parsing it
            if(networkStatus == NOT_REACHABLE ){
                self.navigationController?.popViewControllerAnimated(true)
            }else{
                if let loc2d: CLLocationCoordinate2D =  self.locationManager.currentLocation2d {
                    
                    self.startLatitude = Float(loc2d.latitude)
                    self.startLongitude = Float(loc2d.longitude)
                    self.apiHandler.fetchData(self.locationName, latDest: self.destinationLatitude, lngDest: self.destinationLongitude,latStart: self.startLatitude,lngStart: self.startLongitude)
                    
                } else {
                    
                    self.locationObserver = self.notificationCenter.addObserverForName("LocationDidUpdate", object: nil, queue: self.mainQueue) { _ in
                        
                        if let loc2d: CLLocationCoordinate2D =  self.locationManager.currentLocation2d {
                            
                            self.startLatitude = Float(loc2d.latitude)
                            self.startLongitude = Float(loc2d.longitude)
                            self.apiHandler.fetchData(self.locationName, latDest:self.destinationLatitude,lngDest: self.destinationLongitude,latStart: self.startLatitude,lngStart: self.startLongitude)
                            self.locationManager.hasLocation = true
                        }
                    }
                }
            }
        }
    }
    
    func didReceiveData(results: [Route])  {
        self.resultsRoutes = results
        self.getWalkingDistance()
    }
   

    
    func getWalkingDistance() {
        let uniqRoutes = makeUniqRoutes(self.resultsRoutes)
        let startCoord: CLLocationCoordinate2D = self.locationManager.currentLocation2d!
        uniqRoutes.map({ (thisRoute) -> () in
            self.walkingDirectionsManager.getWalkingDirectionsBetween(startCoord, endLatLon: self.resultsRoutes[0].originLatLon, route: thisRoute)
            println("sending a request!")
            self.walkingRequestsCount++
            })
    }
    
    func handleWalkingDistance(distance: Int, routeTemplate: Route?){
                    println("got back a request!")
                    println("route back is: \(routeTemplate?.originStationName)")
        if let temp = routeTemplate {
            self.walkingRequestsCount--
            // iterate through each results route, and if the station matches, add the distance to the route
            self.resultsRoutes.map({ (route) -> () in
                if routesAreSame(route, temp) {
                    route.distanceToStation = distance
                }
                println("dist: \(route.distanceToStation)")
                println("dist from server: \(distance)")
            })
            
            if self.walkingRequestsCount == 0 {
                self.performSegueWithIdentifier("ResultsSegue", sender: self)
            }
        }
    }
    
    // Error handling-----------------------------------------------------
    
    // This function gets called when the user clicks on the alertView button to dismiss it
    // It performs the unwind segue when done.
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int) {
        timeoutTimer.invalidate()
        self.performSegueWithIdentifier("ErrorUnwindSegue", sender: self)
    }
    
    func handleError(errorMessage: String) {
        self.timeoutTimer.invalidate()
//        self.apiHandler.cancelConnection()
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
        spinner!.stopAnimating()
        timeoutTimer.invalidate()
        
        if segue.identifier == "ResultsSegue" {
            var destinationController = segue.destinationViewController as ResultViewController
            destinationController.resultsRoutes = self.resultsRoutes
        }
    }
}

