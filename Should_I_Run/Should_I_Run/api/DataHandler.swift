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
import SwiftyJSON

let walkingSpeed = 80 //meters per minute
let runningSpeed = 200 //meters per minute

protocol DataHandlerDelegate {
    func handleDataSuccess(_: JSON)
    func handleError(error: String)
}

class DataHandler: NSObject, WalkingDirectionsDelegate, CLLocationManagerDelegate {
    let locationManager = SharedUserLocation
    var walkingDirectionsManager = SharedWalkingDirectionsManager
    var internetReachability: Reachability = Reachability.reachabilityForInternetConnection()
    static var apiHandler = apiController()
    
    var startLatitude = Float()
    var startLongitude = Float()
    
    var delegate:DataHandlerDelegate?
    
    var locationObserver:AnyObject?
    let notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()
    let mainQueue: NSOperationQueue = NSOperationQueue.mainQueue()
    
    var cancelled = false
    
    override init() {
        //get the internet going
        self.internetReachability.connectionRequired()
        self.internetReachability.startNotifier()
    }
    
    static let instance = DataHandler()
    
    func loadTrip() {
        self.cancelled = false
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
    
    
    func receiveLocation(location2d: CLLocationCoordinate2D) {
        apiController.instance.fetchData(Float(location2d.latitude), lngStart: Float(location2d.longitude), success: self.receiveData, fail: self.handleError)
        if self.locationObserver != nil {
            self.notificationCenter.removeObserver(self.locationObserver!)
        }
    }
    
    func cancelLoad() {
        self.cancelled = true
    }

    
    func receiveData(results: JSON)  {
        if self.cancelled != true {
            self.delegate!.handleDataSuccess(results)
        }
    }
    
    // getting walking distance for each route
    // for each route, make a request, wait until it's back, then make next request
//    func queuer() {
//        if self.cancelled == true {
//            return self.handleDone()
//        }
//        
//        if self.walkingDistanceQueue.count > 0 {
//            self.currentWalkingRoute = nil
//            let startCoord: CLLocationCoordinate2D = self.locationManager.currentLocation2d!
//            let temp = self.walkingDistanceQueue.removeAtIndex(0)
//            self.walkingDirectionsManager.getWalkingDirectionsBetween(startCoord, endLatLon: temp.originLatLon)
//            self.currentWalkingRoute = temp
//        } else {
//            if (self.resultsRoutes.count == 0) {
//                self.handleError("Sorry, no results")
//            } else {
//                self.handleDone()
//            }
//        }
//    }
//    
    func handleWalkingDistance(distance: Int){
//        if let temp = self.currentWalkingRoute {
//            // iterate through each results route, and if the station matches, add the distance and times to the route
//            self.resultsRoutes.forEach({ (route) -> () in
//                if originsAreSame(route, routeB: temp) {
//                    route.distanceToStation = distance
//                    route.walkingTime = (distance/walkingSpeed) + route.stationTime
//                    route.runningTime = (distance/runningSpeed) + route.stationTime
//                    let departingIn: Int = Int(route.departureTime! - NSDate.timeIntervalSinceReferenceDate()) / 60
//                    if departingIn < route.walkingTime {
//                        route.shouldRun = true
//                    } else {
//                        route.shouldRun = false
//                    }
//                }
//            })
//        }
//        self.queuer()
    }
//
//    func updateWalkingDistances() {
//        // In the rare event that we don't have a location yet, lets just wait until the next time walking distance is updated
//        if self.locationManager.currentLocation2d == nil {
//            return
//        }
//        
//        self.walkingDistanceQueue = makeUniqRoutes(self.resultsRoutes)
//        self.queuer()
//    }
    
    func handleError(errorMessage: String) {
        self.delegate!.handleError(errorMessage)
    }
}