//
//  cell1.swift
//  ShouldIRun
//
//  Created by Roger Goldfinger on 6/23/15.
//  Copyright © 2015 Should I Run. All rights reserved.
//

import Foundation
import UIKit

class Cell1ViewController: UITableViewCell {
    @IBOutlet weak var timeToNextTrainLabel: UILabel!
    @IBOutlet weak var secondsToNextTrainLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    
    func update(currentBestRoute: Route?, seconds: Int) {
        if let bestRoute = currentBestRoute {
            let currentMinutes = Int(bestRoute.departureTime! - NSDate.timeIntervalSinceReferenceDate()) / 60
            self.timeToNextTrainLabel.text = String(currentMinutes)
            
            if seconds < 10 {
                self.secondsToNextTrainLabel.text = ":0" + String(seconds)
            } else {
                self.secondsToNextTrainLabel.text = ":" + String(seconds)
            }
            
            switch bestRoute.agency {
            case "bart":
                self.destinationLabel.text = "towards \(bestRoute.eolStationName)"
            case "muni":
                self.destinationLabel.text = "\(bestRoute.lineName) towards \(bestRoute.eolStationName)"
            case "caltrain":
                self.destinationLabel.text = "\(bestRoute.lineName) towards \(bestRoute.eolStationName)"
            default:
                self.destinationLabel.text = bestRoute.eolStationName
            }
            
        }
    }
}
