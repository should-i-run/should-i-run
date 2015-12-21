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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.distanceToStationLabel.font = globalNumberStyle
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func update(currentBestRoute: Route?) {
        self.stationNameLabel.numberOfLines = 2
        if let bestRoute = currentBestRoute {
            self.distanceToStationLabel.text = String(bestRoute.distanceToStation!)
            self.stationNameLabel.text = "meters to \(bestRoute.originStationName)"
        }
    }
}