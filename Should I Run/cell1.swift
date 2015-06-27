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
    
    func update(destinationLabelText: String,
        timeToNextTrainLabelText: String,
        secondsToNextTrainLabelText: String) {
            self.timeToNextTrainLabel.text = timeToNextTrainLabelText
            self.secondsToNextTrainLabel.text =
                secondsToNextTrainLabelText
            self.destinationLabel.text = destinationLabelText
    }
    
}
