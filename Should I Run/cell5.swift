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
    
    func update(followingDepartureLabelText: String, followingDepartureSecondsLabelText: String, followingDepartureDestinationLabelText: String) {
        self.followingDepartureLabel.text = followingDepartureDestinationLabelText
        self.followingDepartureDestinationLabel.text = followingDepartureDestinationLabelText
        self.followingDepartureSecondsLabel.text = followingDepartureSecondsLabelText
    }
    
}