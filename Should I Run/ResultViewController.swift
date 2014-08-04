//
//  ResultViewController.swift
//  Should I Run
//
//  Created by Roger Goldfinger on 7/17/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import UIKit
import MapKit

class ResultViewController: UIViewController, CLLocationManagerDelegate, WalkingDirectionsDelegate {
    
    var locationName: String?//temporary, this should be deleted
    let locationManager = SharedUserLocation
    
    var firstRun:Bool = false
    
    let walkingSpeed = 80 //meters per minute
    let runningSpeed = 200 //meters per minute
    let stationTime = 2 //minutes in station
    
    var walkingDirectionsManager = SharedWalkingDirectionsManager
    
    var resultsRoutes = [Route]()
    var currentBestRoute:Route?
    var currentSecondRoute:Route?
    
    
    var distanceToOrigin:Int?

    var departures:[(String, Int)] = []

    

    
    //alarm
    var alarmTime = 0
    
    
    //result area things
    @IBOutlet var resultArea: UIView?
    @IBOutlet var instructionLabel: UILabel?
    @IBOutlet var alarmButton: UIButton?
    
    //    @IBOutlet weak var backButton: UIBarButtonItem!
    
    
    //detial area things
    @IBOutlet var timeToNextTrainLabel: UILabel?
    @IBOutlet var distanceToStationLabel: UILabel?
    @IBOutlet var stationNameLabel: UILabel?
    @IBOutlet var departureStationLabel: UILabel?
    @IBOutlet var destinationLabel: UILabel?
    
    @IBOutlet var timeRunningLabel: UILabel?
    @IBOutlet var timeWalkingLabel: UILabel?
    
    
    @IBOutlet var secondsToNextTrainLabel: UILabel?
    
    //following departure area things
    @IBOutlet var followingDepartureLabel: UILabel?
    @IBOutlet var followingDepartureDestinationLabel: UILabel?
    
    //    @IBOutlet var followingDepartureSecondsLabel: UILabel!
    
    @IBOutlet var followingDepartureSecondsLabel: UILabel?
    
    
    var secondTimer: NSTimer = NSTimer()
    
    var updateResultTimer : NSTimer = NSTimer()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.walkingDirectionsManager.delegate = self
        
        self.secondTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("segueOfSeconds:"), userInfo: nil, repeats: true)
        
        displayResults()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.updateResultTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("updateResults:"), userInfo: nil, repeats: true)

    }
    
    override func viewWillDisappear(animated: Bool) {
        self.updateResultTimer.invalidate()

    }
    
    func displayResults() {
        //calculate
        //logic for when to run
        var foundResult = false
        var walkingTime = 0
        var runningTime = 0
        var distanceToStation = 0
        
        
        for var i = 0; i < self.resultsRoutes.count; ++i {
            if !foundResult {
                
                let route = self.resultsRoutes[i]

                if let dist = self.distanceToOrigin? {
                    distanceToStation = dist
                } else {
                    distanceToStation = route.distanceToStation
                }
                
                walkingTime = (distanceToStation/walkingSpeed) + self.stationTime
                runningTime = (distanceToStation/runningSpeed) + self.stationTime
                
                if route.departureTime > runningTime { //if time to departure is less than time to get to station
                    foundResult = true
                    self.currentBestRoute = route
                    
                    if i + 1 < self.resultsRoutes.count {
                        self.currentSecondRoute = self.resultsRoutes[i + 1]

                    }
                }
            } else {
                //error, no results
            }

            
        }

        
        //result area things
        // run or not?
        if self.currentBestRoute!.departureTime! >= walkingTime {
            self.instructionLabel!.text = "Nah, take it easy"
            self.instructionLabel!.font = UIFont(descriptor: UIFontDescriptor(name: "Helvetica Neue Thin Italic", size: 30), size: 30)
            
            let walkUIColor = colorize(0x90D4D4)
            
            self.resultArea!.backgroundColor = walkUIColor
            
            self.alarmButton!.hidden = false
            self.alarmTime = self.currentBestRoute!.departureTime! - walkingTime
            
        } else {
            
            let runUIColor = colorize(0xF05A28)
            self.resultArea!.backgroundColor = runUIColor
            
            self.instructionLabel!.text = "Run!"
            self.instructionLabel!.font = UIFont(descriptor: UIFontDescriptor(name: "Helvetica Neue Light Italic", size: 30), size: 30)
            self.alarmButton!.hidden = true
            
        }
        
        //detail area things
        
        
        //distance to station label
        self.distanceToStationLabel!.text = String(distanceToStation)
    
        //line and destination station label
        if self.currentBestRoute!.agency == "bart" {
            let destinationStation = bartLookupReverse[self.currentBestRoute!.eolStationName.lowercaseString]!
            self.destinationLabel!.text = "\(self.currentBestRoute!.lineName) / \(destinationStation)"
        } else if self.currentBestRoute!.agency == "muni" {
            self.destinationLabel!.text = "\(self.currentBestRoute!.lineName) / \(self.currentBestRoute!.eolStationName)"
        }
        self.destinationLabel!.adjustsFontSizeToFitWidth = true
        
        
        //departure station name label
        if self.currentBestRoute!.agency == "bart" {
            let name = bartLookupReverse[self.currentBestRoute!.originStationName]!
            self.stationNameLabel!.text = "meters to \(name) station"
        } else if self.currentBestRoute!.agency == "muni" {
            self.stationNameLabel!.text = "meters to \(self.currentBestRoute!.originStationName) station"
        }
        self.stationNameLabel!.adjustsFontSizeToFitWidth = true
        
        //running and walking time labels
        self.timeRunningLabel!.text = String(runningTime)
        self.timeWalkingLabel!.text = String(walkingTime)
        
        
        //timer Labels
        if !firstRun {
          
            // time for the next train
            self.timeToNextTrainLabel!.text = String(self.currentBestRoute!.departureTime!)
            self.secondsToNextTrainLabel!.text = ":00"
            
            //time for the following departure time
            self.followingDepartureLabel!.text = "\(self.currentSecondRoute!.departureTime!)"
            self.followingDepartureSecondsLabel!.text = ":00"
            
            firstRun = true
        }
        
        //following destination station name label
        if self.currentSecondRoute!.agency == "bart" {
            let followingDestinationStation = bartLookupReverse[self.currentSecondRoute!.eolStationName.lowercaseString]!
            self.followingDepartureDestinationLabel!.text = "\(self.currentSecondRoute!.lineName) / \(followingDestinationStation)"
        } else if self.currentSecondRoute!.agency == "muni" {
            self.followingDepartureDestinationLabel!.text = "\(self.currentSecondRoute!.lineName) / \(self.currentSecondRoute!.eolStationName)"
        }
        
        self.followingDepartureDestinationLabel!.adjustsFontSizeToFitWidth = true
        
    }
    
    
    func updateResults(timer: NSTimer){
        
        //call entire reload of display in this function
        let start: CLLocationCoordinate2D =  self.locationManager.currentLocation2d!

        self.walkingDirectionsManager.getWalkingDirectionsBetween(start, endLatLon: self.currentBestRoute!.originLatLon)


    }
    
    func handleWalkingDistance(distance:Int){
        self.distanceToOrigin = distance
        self.displayResults()
        
    }
    
    func segueOfSeconds(timer: NSTimer) {
        //countdown for the next train
        var tempString: NSString = self.secondsToNextTrainLabel!.text
        tempString = tempString.substringFromIndex(1)
        var currentSeconds:Int = tempString.integerValue
        
        if currentSeconds == 0 {
            var currentMinutes:Int = self.timeToNextTrainLabel!.text.toInt()!
            currentMinutes--
            if currentMinutes == 0 {
                currentSeconds = 0
            } else {
                currentSeconds = 59
            }
            
            self.timeToNextTrainLabel!.text = String(currentMinutes)
        } else {
            currentSeconds--
        }
        if currentSeconds < 10 {
            self.secondsToNextTrainLabel!.text = ":0" + String(currentSeconds)
        } else {
            self.secondsToNextTrainLabel!.text = ":" + String(currentSeconds)
        }
        
        //countdown for the following train
        tempString  = self.followingDepartureSecondsLabel!.text
        tempString = tempString.substringFromIndex(1)
        var followingSeconds:Int = tempString.integerValue
        
        if followingSeconds == 0 {
            var followingMinutes:Int = self.followingDepartureLabel!.text.toInt()!
            followingMinutes--
            followingSeconds = 59
            self.followingDepartureLabel!.text = String(followingMinutes)
        } else {
            followingSeconds--
        }
        if followingSeconds < 10 {
            self.followingDepartureSecondsLabel!.text = ":0"+String(followingSeconds)
        } else {
            self.followingDepartureSecondsLabel!.text = ":"+String(followingSeconds)
        }
        
    }
    
    @IBAction func returnToRoot(sender: UIButton) {
        self.navigationController.popToRootViewControllerAnimated(true)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier {
            if segue.identifier == "AlarmSegue" {
                var dest: AddAlarmViewController = segue.destinationViewController as AddAlarmViewController
                dest.walkTime = self.alarmTime
            }
        }
    }
    
}

