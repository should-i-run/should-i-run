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
    
    @IBOutlet weak var followingDepartureSecondsLabel: UILabel!
    @IBOutlet weak var followingDepartureDestinationLabel: UILabel!
    
    func update(secondRoute: Route?, seconds: Int) {
        self.followingDepartureDestinationLabel.numberOfLines = 2
        
        //following destination station name label
        if let following:Route = secondRoute {
            if following.agency == "bart" {
                self.followingDepartureDestinationLabel.text = "towards \(following.eolStationName)"
            } else if following.agency == "muni" {
                self.followingDepartureDestinationLabel.text = following.lineName
            }
            
            self.followingDepartureSecondsLabel.text = following.getFormattedTime()
            self.followingDepartureSecondsLabel.font = UIFont.monospacedDigitSystemFontOfSize(24, weight: UIFontWeightRegular)
            
        } else {
            self.followingDepartureDestinationLabel.text = "No other departures found"
            self.followingDepartureSecondsLabel.hidden = true
        }
    }
}