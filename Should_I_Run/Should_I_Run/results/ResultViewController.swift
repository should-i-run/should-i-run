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

class ResultViewController: UIViewController, DataHandlerDelegate {
    @IBOutlet weak var stationsContainer: ReactView!
    
    var updateResultTimer = NSTimer()
    
    let mainQueue: NSOperationQueue = NSOperationQueue.mainQueue()
    let notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()
    let locationManager = SharedUserLocation
    
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
        
//        self.notificationCenter.addObserverForName("LocationDidUpdate", object: nil, queue: self.mainQueue) {_ in 
//            if let _: CLLocationCoordinate2D = self.locationManager.currentLocation2d {
//                self.updateWalkingDistance()
//            }
//        }
        self.updateResultTimer = NSTimer.scheduledTimerWithTimeInterval(20, target: self, selector: #selector(ResultViewController.updateBart(_:)), userInfo: nil, repeats: true)
    }

    
    func updateBart(timer: NSTimer?) {
        DataHandler.instance.loadTrip()
    }
    
//    func updateWalkingDistance(){
//        DataHandler.instance.updateWalkingDistances()
//    }

    func handleDataSuccess(data: JSON) {
        self.render(data)
    }
    
    func render(data: JSON) {
        self.stationsContainer.updateData(data)
    }
    
    func handleError(error: String) {
        print(error)
    }
}

