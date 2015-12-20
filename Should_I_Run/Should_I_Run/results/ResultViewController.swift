//
//  ResultViewController.swift
//  Should I Run
//
//  Created by Roger Goldfinger on 7/17/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DataHandlerDelegate {
    
    var results = [Route]()
    var currentBestRoute:Route?
    var currentSecondRoute:Route?
    
    var currentSeconds = 0
    
    //alarm
    var alarmTime = 0
    
    //result area things
    @IBOutlet var instructionLabel: UILabel!
    @IBOutlet weak var alarmButton: UIButton!
    @IBOutlet weak var alarmArea: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resultArea: UIView!
    
    var secondTimer: NSTimer = NSTimer()
    var updateResultTimer : NSTimer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem
        self.view.backgroundColor = globalBackgroundColor
        self.tableView.backgroundColor = globalBackgroundColor
        self.resultArea.backgroundColor = globalBackgroundColor

        self.instructionLabel!.hidden = true

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        DataHandler.instance.delegate = self
        DataHandler.instance.cancelled = false
        self.results = DataHandler.instance.getResults()
        
        self.render()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.updateResultTimer = NSTimer.scheduledTimerWithTimeInterval(20, target: self, selector: Selector("updateWalkingDistance:"), userInfo: nil, repeats: true)
        self.secondTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateTimes:"), userInfo: nil, repeats: true)
        
        //get times rendered immediately
        self.updateTimes(nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.currentSecondRoute != nil {
            return 5
        } else {
            return 4
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let rowNum = indexPath.row
        switch rowNum {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("cell1") as! Cell1ViewController
            cell.update(self.currentBestRoute, seconds: self.currentSeconds)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("cell2") as! Cell2ViewController
            cell.update(self.currentBestRoute)
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("cell3") as! Cell3ViewController
            cell.update(self.currentBestRoute)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("cell4") as! Cell4ViewController
            cell.update(self.currentBestRoute)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCellWithIdentifier("cell5") as! Cell5ViewController
            cell.update(self.currentSecondRoute, seconds: self.currentSeconds)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case 2, 3:
            return 60
        default:
            return 90
        }
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func render() {
        if (self.results.count > 0) {
            let firstRoute = self.results[0]
            self.currentBestRoute = firstRoute
        } else {
            self.handleError("No routes found")
            self.updateResultTimer.invalidate()
            self.secondTimer.invalidate()
            self.navigationController?.popViewControllerAnimated(true)
            return
        }
        
        if (self.results.count > 1) {
            let secondRoute = self.results[1]
            self.currentSecondRoute = secondRoute
        }
        
        //------------------result area things
        // run or not?
        if self.currentBestRoute!.shouldRun {
            self.instructionLabel.hidden = false
            let runUIColor = colorize(0xFC5B3F)
            self.instructionLabel.textColor = runUIColor
            self.instructionLabel.text = "Run!"
            if let secondRoute = self.currentSecondRoute {
                self.alarmTime = secondRoute.getCurrentMinutes() - secondRoute.walkingTime
            }

        } else {
            self.instructionLabel.hidden = false
            self.instructionLabel.text = "Take it easy"
            
            let walkUIColor = colorize(0x6FD57F)
            self.instructionLabel.textColor = walkUIColor
            self.alarmTime = (currentBestRoute?.getCurrentMinutes())! - self.currentBestRoute!.walkingTime
        }
        self.tableView.reloadData()
    }
    
    func updateWalkingDistance(timer: NSTimer?){
        DataHandler.instance.updateWalkingDistances()
    }
    
    func handleDataSuccess() {
        self.results = DataHandler.instance.getResults()
        self.render()
    }
    
    func updateTimes(timer: NSTimer?) {
        if self.currentBestRoute != nil && self.currentBestRoute?.getCurrentMinutes() > -1 {
            self.currentSeconds = Int(self.currentBestRoute!.departureTime! - NSDate.timeIntervalSinceReferenceDate()) % 60
            self.tableView.reloadData()
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)

        }
    }
    
    // Segues and unwinds-----------------------------------------------------
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "AlarmSegue" {
            let dest: AddAlarmViewController = segue.destinationViewController as! AddAlarmViewController
            dest.walkTime = self.alarmTime
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        DataHandler.instance.cancelLoad()
        self.updateResultTimer.invalidate()
        self.secondTimer.invalidate()
        super.viewDidDisappear(animated)
    }
    
    // Error handling-----------------------------------------------------
    func handleError(errorMessage: String) {
        let message = UIAlertController(title: "Oops!", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        message.addAction(OKAction)
        self.presentViewController(message, animated: true) {}
        
        
    }
}

