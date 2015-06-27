//
//  cell5.swift
//  ShouldIRun
//
//  Created by Roger Goldfinger on 6/25/15.
//  Copyright © 2015 Should I Run. All rights reserved.
//

import Foundation
import UIKit

class Cell5ViewController: UITableViewCell {
        
    @IBOutlet weak var followingDepartureLabel: UILabel!
    @IBOutlet weak var followingDepartureSecondsLabel: UILabel!
    @IBOutlet weak var followingDepartureDestinationLabel: UILabel!
    
    func update(secondRoute: Route?, seconds: Int) {
        
        //following destination station name label
        if let following:Route = secondRoute {
            if following.agency == "bart" {
                self.followingDepartureDestinationLabel.text = "towards \(following.eolStationName)"
            } else if following.agency == "muni" {
                self.followingDepartureDestinationLabel.text = "\(following.lineName) / \(following.eolStationName)"
            }
            let followingCurrentMinutes = Int(following.departureTime! - NSDate.timeIntervalSinceReferenceDate()) / 60
            self.followingDepartureLabel.text = String(followingCurrentMinutes)
            
            if seconds < 10 {
                self.followingDepartureSecondsLabel.text = ":0" + String(seconds)
            } else {
                self.followingDepartureSecondsLabel.text = ":" + String(seconds)
            }
            
        } else {
            self.followingDepartureDestinationLabel.text = "No other departures found"
            self.followingDepartureSecondsLabel.hidden = true
            self.followingDepartureLabel.hidden = true
        }
    }
}