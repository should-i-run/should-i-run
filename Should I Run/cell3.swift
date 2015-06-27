//
//  cell3.swift
//  ShouldIRun
//
//  Created by Roger Goldfinger on 6/25/15.
//  Copyright © 2015 Should I Run. All rights reserved.
//

import Foundation
import UIKit

class Cell3ViewController: UITableViewCell {
    
    @IBOutlet weak var minutesWalkingLabel: UILabel!
    
    func update(currentBestRoute: Route?) {
        if let bestRoute = currentBestRoute {
            self.minutesWalkingLabel.text = String(bestRoute.walkingTime)
        }
    }
}