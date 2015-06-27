//
//  cell2.swift
//  ShouldIRun
//
//  Created by Roger Goldfinger on 6/25/15.
//  Copyright © 2015 Should I Run. All rights reserved.
//

import Foundation
import UIKit

class Cell2ViewController: UITableViewCell {

    @IBOutlet weak var distanceToStationLabel: UILabel!
    @IBOutlet weak var stationNameLabel: UILabel!
    
    func update(distanceToStationLabelText: String, stationNameLabelText: String) {
        self.distanceToStationLabel.text = distanceToStationLabelText
        self.stationNameLabel.text = stationNameLabelText
    }
    
}