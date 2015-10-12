    //
//  LoadingViewController.swift
//  Should I Run
//
//  Created by Roger Goldfinger on 7/17/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import UIKit
import MapKit

enum NetworkStatusStruct: Int {
    case NotReachable = 0
    case ReachableViaWiFi
    case ReachableViaWWAN
}

class LoadingViewController: UIViewController, UIAlertViewDelegate {
    
    var viewHasAlreadyAppeared = false
    var backgroundColor = UIColor()
    @IBOutlet var spinner: UIActivityIndicatorView?

    var timeoutTimer: NSTimer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start spinner animation
        spinner!.startAnimating()
        
        // Set background color
        self.view.backgroundColor = self.backgroundColor
        
        if !self.viewHasAlreadyAppeared {
            self.viewHasAlreadyAppeared = true
            // Set timer to segue back (by calling segueFromView) back to the main table view
            let timeoutText: Dictionary = ["titleString": "Time Out", "messageString": "Sorry! Your request took too long."]
            self.timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: Selector("timerTimeout:"), userInfo: timeoutText, repeats: false)
        }
    }
    
    // Error handling-----------------------------------------------------

    func timerTimeout(timer: NSTimer) {
        let message: UIAlertView = UIAlertView(title: "Oops!", message: "Request timed out", delegate: self, cancelButtonTitle: "Ok")
        message.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidDisappear(animated: Bool) {
        spinner!.stopAnimating()
        self.timeoutTimer.invalidate()
        super.viewDidDisappear(animated)
    }
}

