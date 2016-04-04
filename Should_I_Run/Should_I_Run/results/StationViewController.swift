//
//  cell1.swift
//  ShouldIRun
//
//  Created by Roger Goldfinger on 6/23/15.
//  Copyright © 2015 Should I Run. All rights reserved.
//

import Foundation
import UIKit

class StationViewController: UITableViewController {
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var runningLabel: UILabel!
    @IBOutlet weak var walkingLabel: UILabel!
    var station: Station?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.distanceLabel.font = globalNumberStyle
        self.runningLabel.font = globalNumberStyle
        self.walkingLabel.font = globalNumberStyle
        self.view.backgroundColor = globalBackgroundColor
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
//        self.tableView.delegate = self
//        self.tableView.dataSource = self
//        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.registerNib(UINib(nibName: "lineCell", bundle: nil), forCellReuseIdentifier: "lineCell")
        self.tableView.reloadData()
        
    }

    func update(station: Station) {
        self.station = station
        self.stationLabel.text = station.stationName
        self.distanceLabel.text = "\(station.distanceToStation!)m"
        self.runningLabel.text = "running: \(station.runningTime)"
        self.walkingLabel.text = "walking: \(station.walkingTime)"
        self.tableView.reloadData()
    }
    
    // Table view stuff
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let s = self.station {
            return s.lines.count
        } else {
            return 0
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("lineCell", forIndexPath: indexPath) as! LineCellController
        let row = indexPath.row as Int
        cell.update(self.station!.lines[row])
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = globalBackgroundColor
    }
}
