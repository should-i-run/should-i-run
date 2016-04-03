//
//  TrainCellController.swift
//  Should_I_Run
//
//  Created by Roger Goldfinger on 4/3/16.
//  Copyright © 2016 Should_I_Run. All rights reserved.
//
import Foundation
import UIKit

class LineCellController: UITableViewCell {

    @IBOutlet weak var lineName: UILabel!
    @IBOutlet weak var time1: UILabel!
    @IBOutlet weak var time2: UILabel!
    @IBOutlet weak var time3: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.time1.font = globalNumberStyle
        self.time2.font = globalNumberStyle
        self.time3.font = globalNumberStyle
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func update(line: Line) {
        self.lineName.text = line.lineName
        self.time1.text = String(line.departures[0].departureTime)
        
        if line.departures.count > 1 {
            self.time2.text = String(line.departures[1].departureTime)
            self.time2.hidden = false
        } else {
            self.time2.hidden = true
        }
        
        if line.departures.count > 2 {
            self.time3.text = String(line.departures[1].departureTime)
            self.time3.hidden = false
        } else {
            self.time3.hidden = true
        }
    }
}
