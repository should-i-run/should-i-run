//
//  ResultViewController.swift
//  Should I Run
//
//  Created by Roger Goldfinger on 7/17/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON

class ResultViewController: UIViewController, DataHandlerDelegate, WalkingDirectionsDelegate {
    var data:JSON?
    var walkingData = Dictionary<String, AnyObject>()
    @IBOutlet weak var stationsContainer: ReactView!
    
    var updateResultTimer = NSTimer()
    var walkingDirectionsObserver:NSObjectProtocol?
    
    let mainQueue: NSOperationQueue = NSOperationQueue.mainQueue()
    let notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()
    let locationManager = SharedUserLocation
    let walkingDirectionsManager = SharedWalkingDirectionsManager
    
    override func viewDidLoad() {
        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.setBackgroundImage(img, forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        super.viewDidLoad()

        DataHandler.instance.delegate = self
        DataHandler.instance.cancelled = false
        DataHandler.instance.loadTrip()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.updateResultTimer = NSTimer.scheduledTimerWithTimeInterval(20, target: self, selector: #selector(ResultViewController.updateBart(_:)), userInfo: nil, repeats: true)
    }
    
    func updateBart(timer: NSTimer?) {
        DataHandler.instance.loadTrip()
    }

    func handleDataSuccess(data: JSON) {
        self.data = data
        self.render()
        if ((self.walkingDirectionsObserver) == nil) {
            self.setupWalkingDirections()
        }
    }
    
    func setupWalkingDirections() {
        self.walkingDirectionsManager.delegate = self
        self.walkingDirectionsObserver = self.notificationCenter.addObserverForName("LocationDidUpdate", object: nil, queue: self.mainQueue) {_ in
            if let _: CLLocationCoordinate2D = self.locationManager.currentLocation2d {
                self.updateWalkingDistances()
            }
        }
        self.updateWalkingDistances()
    }
    
    func updateWalkingDistances() {
        let startCoord: CLLocationCoordinate2D = self.locationManager.currentLocation2d!
        for (_, subJson):(String, JSON) in self.data! {
            let lat = subJson["gtfs_latitude"].doubleValue
            let lng = subJson["gtfs_longitude"].doubleValue
            let code = subJson["abbr"].stringValue
            let endCoord = CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(lng))
            self.walkingDirectionsManager.getWalkingDirectionsBetween(startCoord, endLatLon: endCoord, stationCode: code)
        }
    }
    
    func handleWalkingDistance(stationCode: String, distance: Int, time: Int) {
        self.walkingData[stationCode] = ["distance": distance, "time": time]
        self.render()
    }
    
    func render() {
        self.stationsContainer.updateData(self.data!.object, walkingData: self.walkingData)
    }
    
    func handleError(error: String) {
        print(error)
    }
}

