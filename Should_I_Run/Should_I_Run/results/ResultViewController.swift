//
//  ResultViewController.swift
//  Should I Run
//
//  Created by Roger Goldfinger on 7/17/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController, DataHandlerDelegate {

    var currentRoutes = [Route]()
    var currentStations = [Station]()
    
    //alarm
    var alarmTime = 0
    
    //result area things
    @IBOutlet var instructionLabel: UILabel!
    @IBOutlet weak var alarmButton: UIButton!
    @IBOutlet weak var alarmArea: UIView!
    @IBOutlet weak var resultArea: UIView!
    @IBOutlet weak var stationsContainer: UIView!

    
    
    var secondTimer: NSTimer = NSTimer()
    var updateResultTimer : NSTimer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem
        self.view.backgroundColor = globalBackgroundColor
        self.resultArea.backgroundColor = globalBackgroundColor

        self.instructionLabel!.hidden = true

        DataHandler.instance.delegate = self
        DataHandler.instance.cancelled = false
        self.currentRoutes = DataHandler.instance.getResults()
        self.currentStations = DataHandler.instance.getStations()
        self.render()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.updateResultTimer = NSTimer.scheduledTimerWithTimeInterval(20, target: self, selector: #selector(ResultViewController.updateWalkingDistance(_:)), userInfo: nil, repeats: true)
        self.secondTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(ResultViewController.updateTimes(_:)), userInfo: nil, repeats: true)
        
        //get times rendered immediately
        self.updateTimes(nil)
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
            
            var i = 0 // sorry
            self.childViewControllers.forEach({(vc) in
                if let station = vc as? StationViewController {
                    station.update(self.currentStations[i])
                    i += 1
                }
            })

        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func updateWalkingDistance(timer: NSTimer?){
        DataHandler.instance.updateWalkingDistances()
    }
    
    func handleDataSuccess() {
        self.currentRoutes = DataHandler.instance.getResults()
        self.currentStations = DataHandler.instance.getStations()
        self.render()
    }
    
    func updateTimes(timer: NSTimer?) {
        if self.currentRoutes.count > 0 && self.currentRoutes[0].getCurrentMinutes() > -1 {
            self.render()
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

