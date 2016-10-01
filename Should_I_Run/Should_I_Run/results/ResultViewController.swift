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
    var walkingData = Dictionary<String, Dictionary<String, Int>>()
    @IBOutlet weak var stationsContainer: ReactView!
    
    var updateResultTimer = Timer()
    var walkingDirectionsObserver:NSObjectProtocol?
    
    let mainQueue: OperationQueue = OperationQueue.main
    let notificationCenter: NotificationCenter = NotificationCenter.default
    let locationManager = SharedUserLocation
    let walkingDirectionsManager = SharedWalkingDirectionsManager
    
    override func viewDidLoad() {
        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.setBackgroundImage(img, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        super.viewDidLoad()

        DataHandler.instance.delegate = self
        DataHandler.instance.cancelled = false
        DataHandler.instance.loadTrip()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.updateResultTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(ResultViewController.updateBart(_:)), userInfo: nil, repeats: true)
    }
    
    func updateBart(_ timer: Timer?) {
        DataHandler.instance.loadTrip()
    }

    func handleDataSuccess(_ data: JSON) {
        self.data = data
        self.render()
        if ((self.walkingDirectionsObserver) == nil) {
            self.setupWalkingDirections()
        }
    }
    
    func setupWalkingDirections() {
        self.walkingDirectionsManager.delegate = self
        self.walkingDirectionsObserver = self.notificationCenter.addObserver(forName: NSNotification.Name(rawValue: "LocationDidUpdate"), object: nil, queue: self.mainQueue) {_ in
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
    
    func handleWalkingDistance(_ stationCode: String, distance: Int, time: Int) {
        self.walkingData[stationCode] = ["distance": distance, "time": time]
        self.render()
    }
    
    func render() {
        self.stationsContainer.updateData(self.data!.object as AnyObject, walkingData: self.walkingData as AnyObject)
    }
    
    func handleError(_ error: String) {
        print(error)
    }
}

