//
//  ResultViewController.swift
//  Should I Run
//
//  Created by Roger Goldfinger on 7/17/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {
    
    var locationName: String?//temporary, this should be deleted
    
    let walkingSpeed = 80 //meters per minute
    let runningSpeed = 200 //meters per minute
    let stationTime = 2 //minutes in station
    
    var distance:Int?
    var departureStationName:String?
    var departures:[(String, Int)] = []
    
    //result area things
    @IBOutlet var resultArea: UIView
    @IBOutlet var instructionLabel: UILabel
    @IBOutlet var alarmButton: UIButton


    

    //detial area things
    @IBOutlet var timeToNextTrainLabel: UILabel
    @IBOutlet var distanceToStationLabel: UILabel
    @IBOutlet var stationNameLabel: UILabel
    @IBOutlet var departureStationLabel: UILabel
    @IBOutlet var destinationLabel: UILabel
    
    @IBOutlet var timeRunningLabel: UILabel
    @IBOutlet var timeWalkingLabel: UILabel
    
    
    //following departure area things
    @IBOutlet var followingDepartureLabel: UILabel
    @IBOutlet var followingDepartureDestinationLabel: UILabel

    
    
    override func viewDidLoad() {

        
        super.viewDidLoad()
        

        var destinationStation:String = ""
        var departureTime:Int = 0
        var followingDestinationStation:String = ""
        var followingDepartureTime:Int = 0
        

        
        //calculate
        //logic for when to run
        
        //use distance to generate range of times - running time, walking time
        var walkingTime:Int = (distance!/walkingSpeed) + self.stationTime
        var runningTime:Int = (distance!/runningSpeed) + self.stationTime
        
        
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
                        followingDestinationStation = bartLookupReverse[departures[index + 1].0.lowercaseString]!
                        followingDepartureTime = departures[index + 1].1
                    }
                }
            }
        }

        
        //result area things
            // run or not?
        if departureTime >= walkingTime {
            self.instructionLabel.text = "Nah, take it easy"
            self.instructionLabel.font = UIFont(descriptor: UIFontDescriptor(name: "Helvetica Neue Thin Italic", size: 30), size: 30)
            
            let walkUIColor = colorize(0x90D4D4)
            
            self.resultArea.backgroundColor = walkUIColor
            
            self.alarmButton.hidden = false

        } else {
            
            let runUIColor = colorize(0xF05A28)
            self.resultArea.backgroundColor = runUIColor
            
            self.instructionLabel.text = "Run!"
            self.instructionLabel.font = UIFont(descriptor: UIFontDescriptor(name: "Helvetica Neue Light Italic", size: 30), size: 30)
            self.alarmButton.hidden = true
            
        }
        
        //detial area things
        self.timeToNextTrainLabel.text = String(departureTime)
        self.distanceToStationLabel.text = String(distance!)
        self.destinationLabel.text = "towards \(destinationStation)"
        
        self.stationNameLabel.text = "meters to \(bartLookupReverse[departureStationName!.lowercaseString]) station"
        self.stationNameLabel.adjustsFontSizeToFitWidth = true
        self.timeRunningLabel.text = String(runningTime)
        self.timeWalkingLabel.text = String(walkingTime)
        
        
        //following departure area things
        self.followingDepartureLabel.text = "\(followingDepartureTime)"
        self.followingDepartureDestinationLabel.text = "towards \(followingDestinationStation)"
        
    }
    
    func unwindToList(segue:UIStoryboardSegue)  {

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        
        if segue.identifier {
            if segue.identifier == "AlarmSegue" {
                
                var dest: AddAlarmViewController = segue.destinationViewController as AddAlarmViewController
                
                dest.walkTime = self.timeWalkingLabel.text
                
            }
        }
    }
}

