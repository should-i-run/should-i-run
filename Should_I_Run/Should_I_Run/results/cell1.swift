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
//    @IBOutlet weak var timeToNextTrainLabel: UILabel!
    @IBOutlet weak var timeToNextTrainLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.timeToNextTrainLabel.font = globalNumberStyle
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func update(currentBestRoute: Route?) {
        self.destinationLabel.numberOfLines = 2
        
        if let bestRoute = currentBestRoute {
            
            self.timeToNextTrainLabel.text = bestRoute.getFormattedTime()
            
            switch bestRoute.agency {
            case "bart":
                self.destinationLabel.text = "towards \(bestRoute.eolStationName)"
            case "muni":
                self.destinationLabel.text = bestRoute.lineName
            case "caltrain":
                self.destinationLabel.text = "towards \(bestRoute.eolStationName)"
            default:
                self.destinationLabel.text = bestRoute.eolStationName
            }
            
        }
    }
}
