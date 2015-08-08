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

class LoadingViewController: UIViewController, UIAlertViewDelegate, DataHandlerDelegate {
    
    var viewHasAlreadyAppeared = false
    var backgroundColor = UIColor()
    @IBOutlet var spinner: UIActivityIndicatorView?

    var timeoutTimer: NSTimer = NSTimer()
    
    override func viewWillAppear(animated: Bool) {
        DataHandler.instance.delegate = self
    }
    
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
    
    func handleDataSuccess () {
        self.performSegueWithIdentifier("ResultsSegue", sender: self)
    }
    
    // Error handling-----------------------------------------------------
    
    // This function gets called when the user clicks on the alertView button to dismiss it
    // It performs the unwind segue when done.
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        self.performSegueWithIdentifier("ErrorUnwindSegue", sender: self)
    }
    
    func handleError(errorMessage: String) {
        self.timeoutTimer.invalidate()
        DataHandler.instance.cancelLoad()
        // Create and show error message
        // delegates to the alertView function above when 'Ok' is clicked and then perform unwind segue to previous screen.
        let message: UIAlertView = UIAlertView(title: "Oops!", message: errorMessage, delegate: self, cancelButtonTitle: "Ok")
        message.show()
    }
    
    func timerTimeout(timer: NSTimer) {
        handleError("Request timed out")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)  {
        spinner!.stopAnimating()
        self.timeoutTimer.invalidate()
    }
}

