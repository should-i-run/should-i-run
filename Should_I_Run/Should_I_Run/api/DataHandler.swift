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

protocol DataHandlerDelegate {
    func handleDataSuccess(_: JSON)
    func handleError(error: String)
}

class DataHandler: NSObject, CLLocationManagerDelegate {
    let locationManager = SharedUserLocation
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
    
    func handleError(errorMessage: String) {
        self.delegate!.handleError(errorMessage)
    }
}