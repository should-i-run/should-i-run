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
    
    
    var distanceToOrigin:Int?
    var departureStationName:String?
    var departures:[(String, Int)] = []
    var bartOriginStationLocation:(lat: String, lon: String)?
    var muniOriginStationLocation:(lat: String, lon: String)?
    
    var muniResults:[(departureTime: Int, distanceToStation: String, originStationName: String, lineName: String, eolStationName: String, originLatLon:(lat:String, lon:String))]?
    
    //alarm
    var alarmTime = 0
    
    //for displaying results
    var destinationStation:String = ""
    var departureTime:Int = 0
    var followingDestinationStation:String = ""
    var followingDepartureTime:Int = 0
    
    var walkingTime:Int?
    var runningTime:Int?
    
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
        if !muniResults? {
            //use distance to generate range of times - running time, walking time
            walkingTime = (self.distanceToOrigin!/walkingSpeed) + self.stationTime
            runningTime = (self.distanceToOrigin!/runningSpeed) + self.stationTime
            
            
            var foundResult = false
            
            //go through list of possible times.
            for (index, departure) in enumerate(departures) {
                if foundResult == false {
                    //subtract the estimated station time from it
                    //find the first one that is > running time. This is our result
                    if departure.1 > runningTime {
                        foundResult = true
                        destinationStation = bartLookupReverse[departure.0.lowercaseString]!
                        departureTime = departure.1
                        
                        //next one is the subsequent train
                        if index + 1 < departures.count {
                            followingDestinationStation = "\(bartLookupReverse[departures[index + 1].0.lowercaseString]!)"
                            followingDepartureTime = departures[index + 1].1
                        }
                    }
                }
            }
        } else {
            
            var foundResult = false
            
            for var i = 0; i < self.muniResults!.count; ++i {
                if !foundResult {
                    
                    let thisDeparture = self.muniResults![i]
                    var dist = 0
                    if self.distanceToOrigin {
                        dist = self.distanceToOrigin!
                    } else {
                        dist = thisDeparture.distanceToStation.toInt()!
                    }
                    
                    
                    walkingTime = (dist/walkingSpeed) + self.stationTime
                    runningTime = (dist/runningSpeed) + self.stationTime
                    
                    if thisDeparture.departureTime > runningTime { //if time to departure is less than time to get to station
                        foundResult = true
                        destinationStation = "\(thisDeparture.lineName) / \(thisDeparture.eolStationName)"
                        departureTime = thisDeparture.departureTime
                        departureStationName = thisDeparture.originStationName
                        //sets the class global distance to the current distance
                        self.distanceToOrigin = dist
                        self.muniOriginStationLocation = thisDeparture.originLatLon
                        
                        if i + 1 < self.muniResults!.count {
                            let nextDeparture = self.muniResults![i + 1]
                            followingDestinationStation = "\(nextDeparture.lineName) / \(nextDeparture.eolStationName)"
                            followingDepartureTime = nextDeparture.departureTime
                        }
                    }
                }
            }
            
            if !foundResult {
                //error, no result
            }
            
        }
        
        //result area things
        // run or not?
        if departureTime >= walkingTime {
            self.instructionLabel!.text = "Nah, take it easy"
            self.instructionLabel!.font = UIFont(descriptor: UIFontDescriptor(name: "Helvetica Neue Thin Italic", size: 30), size: 30)
            
            let walkUIColor = colorize(0x90D4D4)
            
            self.resultArea!.backgroundColor = walkUIColor
            
            self.alarmButton!.hidden = false
            self.alarmTime = departureTime - walkingTime!
            
        } else {
            
            let runUIColor = colorize(0xF05A28)
            self.resultArea!.backgroundColor = runUIColor
            
            self.instructionLabel!.text = "Run!"
            self.instructionLabel!.font = UIFont(descriptor: UIFontDescriptor(name: "Helvetica Neue Light Italic", size: 30), size: 30)
            self.alarmButton!.hidden = true
            
        }
        
        //detail area things
        
        
        
        self.distanceToStationLabel!.text = String(self.distanceToOrigin!)
        self.destinationLabel!.text = destinationStation
        self.destinationLabel!.adjustsFontSizeToFitWidth = true
        
        
        
        self.stationNameLabel!.text = "meters to \(departureStationName!) station"
        self.stationNameLabel!.adjustsFontSizeToFitWidth = true
        self.timeRunningLabel!.text = String(runningTime!)
        self.timeWalkingLabel!.text = String(walkingTime!)
        
        if !firstRun {
            //time for the following departure ime
            self.followingDepartureLabel!.text = "\(followingDepartureTime)"
            self.followingDepartureSecondsLabel!.text = ":00"
            
            // time for the next train
            self.timeToNextTrainLabel!.text = String(departureTime)
            self.secondsToNextTrainLabel!.text = ":00"
            
            firstRun = true
        }
        
        
        //other details for the following departure ime
        self.followingDepartureDestinationLabel!.text = followingDestinationStation
        self.followingDepartureDestinationLabel!.adjustsFontSizeToFitWidth = true
        
    }
    
    
    func updateResults(timer: NSTimer){
        
        //call entire reload of display in this function
        let loc2d: CLLocationCoordinate2D =  self.locationManager.currentLocation2d!
        var startLatitude = (loc2d.latitude as NSNumber).stringValue
        var startLongitude = (loc2d.longitude as NSNumber).stringValue
        
        var start = (lat: startLatitude!,lon: startLongitude!)
        
        if muniResults{
            self.walkingDirectionsManager.getWalkingDirectionsBetween(start, endLatLon: self.muniOriginStationLocation!)
        } else {
            self.walkingDirectionsManager.getWalkingDirectionsBetween(start, endLatLon: self.bartOriginStationLocation!)
        }
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

