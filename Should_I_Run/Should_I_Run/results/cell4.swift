//
//  File.swift
//  ShouldIRun
//
//  Created by Roger Goldfinger on 6/25/15.
//  Copyright © 2015 Should I Run. All rights reserved.
//

import Foundation
import UIKit

class Cell4ViewController: UITableViewCell {
    
    @IBOutlet weak var timeRunningLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.timeRunningLabel.font = globalNumberStyle
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func update(currentBestRoute: Route?) {
        if let bestRoute = currentBestRoute {
            self.timeRunningLabel.text = String(bestRoute.runningTime)
        }
    }
}