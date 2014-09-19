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
    
    let locationManager = SharedUserLocation
    
    let walkingSpeed = 80 //meters per minute
    let runningSpeed = 200 //meters per minute
    let stationTime = 2 //minutes in station
    
    var walkingDirectionsManager = SharedWalkingDirectionsManager
    
    var resultsRoutes = [Route]()
    var currentBestRoute:Route?
    var currentSecondRoute:Route?
    
    var currentSeconds = 0
    var currentMinutes = 0
    var followingCurrentMinutes:Int? = 0
    
    var distanceToOrigin:Int?
    
    //alarm
    var alarmTime = 0
    
    
    //result area things
    @IBOutlet var resultArea: UIView!
    @IBOutlet var instructionLabel: UILabel!
    @IBOutlet var alarmButton: UIButton!
    
    //detial area things
    @IBOutlet var timeToNextTrainLabel: UILabel!
    @IBOutlet var distanceToStationLabel: UILabel!
    @IBOutlet var stationNameLabel: UILabel!
    @IBOutlet var departureStationLabel: UILabel!
    @IBOutlet var destinationLabel: UILabel!
    
    @IBOutlet var timeRunningLabel: UILabel!
    @IBOutlet var timeWalkingLabel: UILabel!
    @IBOutlet var secondsToNextTrainLabel: UILabel!
    
    //following departure area things
    @IBOutlet var followingDepartureLabel: UILabel!
    @IBOutlet var followingDepartureDestinationLabel: UILabel!
    @IBOutlet var followingDepartureSecondsLabel: UILabel!
    
    @IBOutlet weak var followingTimeTextLabel: UILabel!
    
    var secondTimer: NSTimer = NSTimer()
    var updateResultTimer : NSTimer = NSTimer()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //double check that we have some results
        if self.resultsRoutes.count == 0 {
            self.handleError("Couldn't find any routes")
        }
        
        self.view.backgroundColor = globalBackgroundColor
        
        self.instructionLabel!.hidden = true
        self.alarmButton!.hidden = true
        
        self.edgesForExtendedLayout = UIRectEdge() // so that the views are the same distance from the navbar in both ios 7 and 8
        
        self.walkingDirectionsManager.delegate = self
        
        self.updateWalkingDistance(nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.updateResultTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("updateWalkingDistance:"), userInfo: nil, repeats: true)
        self.secondTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateTimes:"), userInfo: nil, repeats: true)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        self.updateResultTimer.invalidate()
        self.secondTimer.invalidate()

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
                
                let departingIn: Int = Int(route.departureTime! - NSDate.timeIntervalSinceReferenceDate()) / 60
                
                if departingIn > runningTime { //if time to departure is less than time to get to station
                    foundResult = true
                    self.currentBestRoute = route
                    self.currentMinutes = departingIn
                    self.currentSeconds = Int(route.departureTime! - NSDate.timeIntervalSinceReferenceDate()) % 60
                    
                    //set the following route if there is one
                    if i + 1 < self.resultsRoutes.count {
                        self.currentSecondRoute = self.resultsRoutes[i + 1]
                        self.followingCurrentMinutes = Int(self.resultsRoutes[i + 1].departureTime! - NSDate.timeIntervalSinceReferenceDate()) / 60

                    }
                }
            }
        }
        
        // if there is no viable route, error
        if self.currentBestRoute == nil || foundResult == false {
            self.handleError("sorry, couldn't find any routes")
            self.updateResultTimer.invalidate()
            self.secondTimer.invalidate()
            return
        }
        
        
        //result area things
        // run or not?
        if self.currentMinutes >= walkingTime {
            self.instructionLabel.hidden = false
            self.instructionLabel.text = "Nah, take it easy"
            self.instructionLabel.font = UIFont(descriptor: UIFontDescriptor(name: "Helvetica Neue Thin Italic", size: 30), size: 30)
            
            let walkUIColor = colorize(0x6FD57F)
            
            self.resultArea.backgroundColor = walkUIColor
            
            self.alarmButton.hidden = false
            self.alarmTime = self.currentMinutes - walkingTime
            
        } else {
            self.instructionLabel.hidden = false
            let runUIColor = colorize(0xFC5B3F)
            self.resultArea!.backgroundColor = runUIColor
            
            self.instructionLabel.text = "Run!"
            self.instructionLabel.font = UIFont(descriptor: UIFontDescriptor(name: "Helvetica Neue Light Italic", size: 50), size: 50)
            self.alarmButton.hidden = true
            
        }
        
        //detail area things
        
        
        //distance to station label
        self.distanceToStationLabel.text = String(distanceToStation)
    
        //line and destination station label, departure station label
        if self.currentBestRoute!.agency == "bart" {
            
            let destinationStation = bartLookupReverse[self.currentBestRoute!.eolStationName.lowercaseString]!
            self.destinationLabel.text = "towards \(destinationStation)"
            
            if let name = bartLookupReverse[self.currentBestRoute!.originStationName] {
                self.stationNameLabel.text = "meters to \(name) station"
            } else {
                self.stationNameLabel.text = "meters to \(self.currentBestRoute!.originStationName) station"
            }
            
        } else if self.currentBestRoute!.agency == "muni" {
            self.destinationLabel.text = "\(self.currentBestRoute!.lineName) / \(self.currentBestRoute!.eolStationName)"
            self.stationNameLabel.text = "meters to \(self.currentBestRoute!.originStationName)"
            
        } else if self.currentBestRoute!.agency == "caltrain" {
            self.destinationLabel.text = "\(self.currentBestRoute!.lineName) towards \(self.currentBestRoute!.eolStationName)"
            self.stationNameLabel.text = "meters to \(self.currentBestRoute!.originStationName)"
        }
        
        //running and walking time labels
        self.timeRunningLabel.text = String(runningTime)
        self.timeWalkingLabel.text = String(walkingTime)
        
        
        //timer Labels
        self.updateTimes(nil)

        
        //following destination station name label
        if let following:Route = self.currentSecondRoute {
            if following.agency == "bart" {
                if let followingDestinationStation = bartLookupReverse[following.eolStationName.lowercaseString] {
                    self.followingDepartureDestinationLabel.text = "towards \(followingDestinationStation)"
                } else {
                    self.followingDepartureDestinationLabel.text = "towards \(following.eolStationName)"
                }
            } else if following.agency == "muni" {
                self.followingDepartureDestinationLabel.text = "\(following.lineName) / \(following.eolStationName)"
            }
        } else {
            self.followingDepartureDestinationLabel.text = "No other departures found"
            self.followingDepartureSecondsLabel.hidden = true
            self.followingDepartureLabel.hidden = true
            self.followingTimeTextLabel.hidden = true
        }
        
    }
    
    func updateWalkingDistance(timer: NSTimer?){
        
        //in the rare event that we don't have a location yet, lets just wait until the next time walking distance is updated
        if self.locationManager.currentLocation2d == nil {
            return
        }
        let start: CLLocationCoordinate2D =  self.locationManager.currentLocation2d!
        
        if self.currentBestRoute != nil {
            self.walkingDirectionsManager.getWalkingDirectionsBetween(start, endLatLon: self.currentBestRoute!.originLatLon)
        } else if self.resultsRoutes.count != 0 {
             self.walkingDirectionsManager.getWalkingDirectionsBetween(start, endLatLon: self.resultsRoutes[0].originLatLon)
        }



    }
    
    func handleWalkingDistance(distance:Int){
        self.distanceToOrigin = distance
        self.displayResults()
        
    }
    
    func updateTimes(timer: NSTimer?) {

        if self.currentBestRoute != nil {
            self.currentMinutes = Int(self.currentBestRoute!.departureTime! - NSDate.timeIntervalSinceReferenceDate()) / 60
            
            // check that we haven't run out of time
            // if so, segue back
            if self.currentMinutes < -1 {
                self.returnToRoot(nil)
                self.updateResultTimer.invalidate()
                self.secondTimer.invalidate()
                return
            }
            
            self.currentSeconds = Int(self.currentBestRoute!.departureTime! - NSDate.timeIntervalSinceReferenceDate()) % 60
            
            if self.currentSecondRoute != nil {
                self.followingCurrentMinutes = Int(self.currentSecondRoute!.departureTime! - NSDate.timeIntervalSinceReferenceDate()) / 60
                self.followingDepartureLabel.text = String(self.followingCurrentMinutes!)
            }
            
            

            self.timeToNextTrainLabel.text = String(currentMinutes)
            
            if self.currentSeconds < 10 {
                self.secondsToNextTrainLabel.text = ":0" + String(currentSeconds)
                self.followingDepartureSecondsLabel.text = ":0" + String(currentSeconds)
            } else {
                self.secondsToNextTrainLabel.text = ":" + String(currentSeconds)
                self.followingDepartureSecondsLabel.text = ":" + String(currentSeconds)
            }
        } 
        
    }
    
    // Segues and unwinds-----------------------------------------------------
    
    @IBAction func returnToRoot(sender: UIButton?) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func unwindToResults(segue: UIStoryboardSegue) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {

        if segue.identifier == "AlarmSegue" {
            var dest: AddAlarmViewController = segue.destinationViewController as AddAlarmViewController
            dest.walkTime = self.alarmTime
        }

    }
    

    
    // Error handling-----------------------------------------------------
    
    
    // This function gets called when the user clicks on the alertView button to dismiss it (see didReceiveGoogleResults)
    // It performs the unwind segue when done.
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int) {
        self.returnToRoot(nil)
    }
    
    func handleError(errorMessage: String) {
        // Create and show error message
        // delegates to the alertView function above when 'Ok' is clicked and then perform unwind segue to previous screen.
        var message: UIAlertView = UIAlertView(title: "Oops!", message: errorMessage, delegate: self, cancelButtonTitle: "Ok")
        message.show()
        
    }
    
}

