//
//  ResultViewController.swift
//  Should I Run
//
//  Created by Roger Goldfinger on 7/17/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DataHandlerDelegate {

    var currentRoutes = [Route]()
    
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
        self.currentRoutes = DataHandler.instance.getResults()
        self.render()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.updateResultTimer = NSTimer.scheduledTimerWithTimeInterval(20, target: self, selector: #selector(ResultViewController.updateWalkingDistance(_:)), userInfo: nil, repeats: true)
        self.secondTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(ResultViewController.updateTimes(_:)), userInfo: nil, repeats: true)
        
        //get times rendered immediately
        self.updateTimes(nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.currentRoutes.count >= 2 {
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
            cell.update(self.currentRoutes[0])
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("cell2") as! Cell2ViewController
            cell.update(self.currentRoutes[0])
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("cell3") as! Cell3ViewController
            cell.update(self.currentRoutes[0])
            return cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("cell4") as! Cell4ViewController
            cell.update(self.currentRoutes[0])
            return cell
        case 4:
            let cell = tableView.dequeueReusableCellWithIdentifier("cell5") as! Cell5ViewController
            cell.update(self.currentRoutes[1])
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
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = globalBackgroundColor
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
//        if motion == .MotionShake {
//            apiController.instance.logApiResponse()
//            if let bestRoute = self.currentRoutes[0] {
//                print("--- Current Best Route:")
//                print(bestRoute.toString())
//            }
//            if let secondRoute = self.currentRoutes[1] {
//                print("--- Second BestRoute:")
//                print(secondRoute.toString())
//            }
//        }
    }
    
    func render() {
        if self.currentRoutes.count > 0 {
            //------------------result area things
            // run or not?
            if self.currentRoutes[0].shouldRun {
                self.instructionLabel.hidden = false
                let runUIColor = colorize(0xFC5B3F)
                self.instructionLabel.textColor = runUIColor
                self.instructionLabel.text = "Run!"
                if self.currentRoutes.count > 1 {
                    let secondRoute = self.currentRoutes[1]
                    self.alarmTime = secondRoute.getCurrentMinutes() - secondRoute.walkingTime
                }
                
            } else {
                self.instructionLabel.hidden = false
                self.instructionLabel.text = "Take it easy"
                let walkUIColor = colorize(0x6FD57F)
                self.instructionLabel.textColor = walkUIColor
                
                let bestRoute = self.currentRoutes[0]
                self.alarmTime = bestRoute.getCurrentMinutes() - bestRoute.walkingTime
            }
            self.tableView.reloadData()
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func updateWalkingDistance(timer: NSTimer?){
        DataHandler.instance.updateWalkingDistances()
    }
    
    func handleDataSuccess() {
        self.currentRoutes = DataHandler.instance.getResults()
        self.render()
    }
    
    func updateTimes(timer: NSTimer?) {
        if self.currentRoutes.count > 0 && self.currentRoutes[0].getCurrentMinutes() > -1 {
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

