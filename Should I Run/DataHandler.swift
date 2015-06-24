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

let walkingSpeed = 80 //meters per minute
let runningSpeed = 200 //meters per minute

protocol DataHandlerDelegate {
    func handleDataSuccess()
    func handleError(String)
}

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
    
    var delegate:DataHandlerDelegate?
    
    var locationObserver:AnyObject?
    let notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()
    let mainQueue: NSOperationQueue = NSOperationQueue.mainQueue()
    
    override init() {
        //get the internet going
        self.internetReachability.connectionRequired()
        self.internetReachability.startNotifier()
    }
    
    static let instance = DataHandler()
    
    func loadTrip(name: String, lat: Float, lon: Float) {
        self.destinationLatitude = lat
        self.destinationLongitude = lon
        let networkStatus = self.internetReachability.currentReachabilityStatus()
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
    
    func getResults() -> [Route] {
        var results = [Route]()
        var foundResult = false
        var distanceToStation = 0
        
        for var i = 0; i < self.resultsRoutes.count; ++i {
            if !foundResult {
                
                let route = self.resultsRoutes[i]
                distanceToStation = route.distanceToStation!
                
                route.walkingTime = (distanceToStation/walkingSpeed) + route.stationTime
                route.runningTime = (distanceToStation/runningSpeed) + route.stationTime
                
                let departingIn: Int = Int(route.departureTime! - NSDate.timeIntervalSinceReferenceDate()) / 60
                if departingIn > route.runningTime { //if time to departure is less than time to get to station
                    foundResult = true
                    let departingIn: Int = Int(route.departureTime! - NSDate.timeIntervalSinceReferenceDate()) / 60
                    if departingIn >= route.walkingTime {
                        route.shouldRun = true
                    }
                    
                    results.append(route)
                    
                    //set the following route if there is one
                    if i + 1 < self.resultsRoutes.count {
                        results.append(self.resultsRoutes[i + 1])

                    }
                }
            }
        }
        
        return results;
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
            let temp = self.walkingDistanceQueue.removeAtIndex(0)
            self.walkingDirectionsManager.getWalkingDirectionsBetween(startCoord, endLatLon: temp.originLatLon)
            self.currentWalkingRoute = temp
        } else {
            if (self.resultsRoutes.count == 0) {
                self.handleError("Sorry, no results")
            } else {
                self.handleDone()
            }
        }
    }
    
    func handleWalkingDistance(distance: Int){
        if let temp = self.currentWalkingRoute {
            // iterate through each results route, and if the station matches, add the distance to the route
            self.resultsRoutes.map({ (route) -> () in
                if originsAreSame(route, routeB: temp) {
                    route.distanceToStation = distance
                }
            })
        }
        self.queuer()
    }
    
    func updateWalkingDistances() {
        //in the rare event that we don't have a location yet, lets just wait until the next time walking distance is updated
        if self.locationManager.currentLocation2d == nil {
            return
        }
        let start: CLLocationCoordinate2D =  self.locationManager.currentLocation2d!
        
        self.walkingDistanceQueue = makeUniqRoutes(self.resultsRoutes)
        self.queuer()
    }
    
    func handleError(errorMessage: String) {
        self.delegate!.handleError(errorMessage)
    }
    
    func handleDone() {
        self.delegate!.handleDataSuccess()
    }
}