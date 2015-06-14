//
//  ApiPresenter.swift
//  ShouldIRun
//
//  Created by Roger Goldfinger on 6/14/15.
//  Copyright (c) 2015 Should I Run. All rights reserved.
//
import UIKit
import MapKit
import Foundation

class DataHandler: NSObject, WalkingDirectionsDelegate, CLLocationManagerDelegate {
    let locationManager = SharedUserLocation
    var walkingDirectionsManager = SharedWalkingDirectionsManager
    var walkingDistanceQueue = [Route]()
    var currentWalkingRoute : Route?
    var internetReachability: Reachability = Reachability.reachabilityForInternetConnection()
    static var apiHandler = apiController()
    var resultsRoutes = [Route]()
    
    var locationName = String()
    var destinationLatitude = Float()
    var destinationLongitude = Float()
    
    var startLatitude = Float()
    var startLongitude = Float()
    
    var loadingView: LoadingViewController?
    
    var locationObserver:AnyObject?
    let notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()
    let mainQueue: NSOperationQueue = NSOperationQueue.mainQueue()
    
    override init() {
        //get the internet going
        self.internetReachability.connectionRequired()
        self.internetReachability.startNotifier()
    }
    
    static let instance = DataHandler()
    
    func loadTrip(name: String, lat: Float, lon: Float, color: UIColor) {
        var networkStatus = self.internetReachability.currentReachabilityStatus()
        if (networkStatus == NOT_REACHABLE ) {
            self.handleError("Sorry, no internet access")
        } else {
            // If we don't yet have a location, register an observer
            if let loc2d: CLLocationCoordinate2D =  self.locationManager.currentLocation2d {
                self.receiveLocation(loc2d)
            } else {
                self.locationObserver = self.notificationCenter.addObserverForName("LocationDidUpdate", object: nil, queue: self.mainQueue) { _ in
                    if let loc2d: CLLocationCoordinate2D =  self.locationManager.currentLocation2d {
                        self.receiveLocation(loc2d)
                    }
                }
            }
        }

        self.walkingDirectionsManager.delegate = self
    }
    
    func getRoutes() -> [Route] {
        return self.resultsRoutes;
    }
    
    func receiveLocation(location2d: CLLocationCoordinate2D) {
        self.startLatitude = Float(location2d.latitude)
        self.startLongitude = Float(location2d.longitude)
        apiController.instance.fetchData(self.locationName, latDest: self.destinationLatitude, lngDest: self.destinationLongitude, latStart: self.startLatitude, lngStart: self.startLongitude, success: self.receiveData, fail: self.handleError)
        if self.locationObserver != nil {
            self.notificationCenter.removeObserver(self.locationObserver!)
        }
    }
    
    func receiveData(results: [Route])  {
        self.resultsRoutes = results
        self.walkingDistanceQueue = makeUniqRoutes(self.resultsRoutes)
        self.queuer()
    }
    
    // getting walking distance for each route
    // for each route, make a request, wait until it's back, then make next request
    func queuer() {
        if self.walkingDistanceQueue.count > 0 {
            self.currentWalkingRoute = nil
            let startCoord: CLLocationCoordinate2D = self.locationManager.currentLocation2d!
            var temp = self.walkingDistanceQueue.removeAtIndex(0)
            self.walkingDirectionsManager.getWalkingDirectionsBetween(startCoord, endLatLon: temp.originLatLon)
            self.currentWalkingRoute = temp
        } else {
            self.loadingView!.performSegueWithIdentifier("ResultsSegue", sender: self.loadingView!)
        }
    }
    
    func handleWalkingDistance(distance: Int){
        if let temp = self.currentWalkingRoute {
            // iterate through each results route, and if the station matches, add the distance to the route
            self.resultsRoutes.map({ (route) -> () in
                if originsAreSame(route, temp) {
                    route.distanceToStation = distance
                }
            })
        }
        self.queuer()
    }
    
    func handleError(errorMessage: String) {
        self.loadingView!.handleError(errorMessage)
    }
}