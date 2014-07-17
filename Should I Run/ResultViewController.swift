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
    @IBOutlet var departureStationLabel: UILabel
    @IBOutlet var destinationLabel: UILabel

    

    //detial area things
    @IBOutlet var timeToNextTrainLabel: UILabel
    @IBOutlet var distanceToStationLabel: UILabel
    @IBOutlet var timeRunningLabel: UILabel
    @IBOutlet var timeWalkingLabel: UILabel
    
    
    //following departure area things
    @IBOutlet var followingDepartureLabel: UILabel
    @IBOutlet var followingDepartureDestinationLabel: UILabel

    
    
    override func viewDidLoad() {
        println("in results view controller")
        super.viewDidLoad()
        

        var destinationStation:String = ""
        var departureTime:Int = 0
        var followingDestinationStation:String = ""
        var followingDepartureTime:Int = 0
        

        
        //calculate
        //logic for when to run
        
        //use distance to generate range of times - running time, walking time
        var walkingTime:Int = distance!/walkingSpeed
        var runningTime:Int = distance!/runningSpeed
        
        
        var foundResult = false
        
        //go through list of possible times.
        for (index, departure) in enumerate(departures) {
            if foundResult == false {
                //subtract the estimated station time from it
                //find the first one that is > running time. This is our result
                if departure.1 - self.stationTime >= runningTime {
                    foundResult = true
                    destinationStation = departure.0
                    departureTime = departure.1
                    //need to check that we don't go past the end of the array
                    //next one is the subsequent train
                    followingDestinationStation = departures[index + 1].0
                    followingDepartureTime = departures[index + 1].1
                }
            }
        }

        
        //result area things
//        resultArea: UIView
//        instructionLabel: UILabel
        departureStationLabel.text = departureStationName
        destinationLabel.text = "towards \(destinationStation)"
        
        
        //detial area things
        timeToNextTrainLabel.text = String(departureTime)
        distanceToStationLabel.text = String(distance!)
        timeRunningLabel.text = String(runningTime)
        timeWalkingLabel.text = String(walkingTime)
        
        
        //following departure area things
        followingDepartureLabel.text = "\(followingDepartureTime) minutes"
        followingDepartureDestinationLabel.text = "towards \(followingDestinationStation)"
        
        }

}

