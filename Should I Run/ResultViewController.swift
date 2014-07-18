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
        
        func colorize (hex: Int, alpha: Double = 1.0) -> UIColor {
            let red = Double((hex & 0xFF0000) >> 16) / 255.0
            let green = Double((hex & 0xFF00) >> 8) / 255.0
            let blue = Double((hex & 0xFF)) / 255.0
            var color: UIColor = UIColor( red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha:CGFloat(alpha) )
            return color
        }

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
                    destinationStation = departure.0
                    departureTime = departure.1

                    //next one is the subsequent train
                    if index + 1 < departures.count {
                        followingDestinationStation = departures[index + 1].0
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
        
        self.stationNameLabel.text = "meters to \(departureStationName) station"
        self.stationNameLabel.adjustsFontSizeToFitWidth = true
        self.timeRunningLabel.text = String(runningTime)
        self.timeWalkingLabel.text = String(walkingTime)
        
        
        //following departure area things
        self.followingDepartureLabel.text = "\(followingDepartureTime)"
        self.followingDepartureDestinationLabel.text = "to \(followingDestinationStation)"
        
        }

}

