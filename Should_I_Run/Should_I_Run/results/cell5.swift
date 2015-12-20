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
    
    @IBOutlet weak var followingDepartureTimeLabel: UILabel!
    @IBOutlet weak var followingDepartureDestinationLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.followingDepartureTimeLabel.font = globalNumberStyle
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func update(secondRoute: Route?) {
        self.followingDepartureDestinationLabel.numberOfLines = 2
        
        //following destination station name label
        if let following:Route = secondRoute {
            if following.agency == "bart" {
                self.followingDepartureDestinationLabel.text = "towards \(following.eolStationName)"
            } else if following.agency == "muni" {
                self.followingDepartureDestinationLabel.text = following.lineName
            }
            
            self.followingDepartureTimeLabel.text = following.getFormattedTime()
            
        } else {
            self.followingDepartureDestinationLabel.text = "No other departures found"
            self.followingDepartureTimeLabel.hidden = true
        }
    }
}