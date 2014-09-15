//
//  AddAlarmViewController.swift
//  Should I Run
//
//  Created by Kyle Craft on 7/17/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import UIKit

class AddAlarmViewController: UIViewController {
    
    @IBOutlet var alarmPicker: UIDatePicker!
    var walkTime: Int?
    
    
    @IBAction func saveBarButtonPress(sender: AnyObject) {

        var localNotification:UILocalNotification = UILocalNotification()
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.alertBody = "Time to go"
        localNotification.alertAction = "Should I Run?"
        localNotification.fireDate = NSDate(timeIntervalSinceNow: alarmPicker.countDownDuration)

        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        self.performSegueWithIdentifier("backToResults", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alarmPicker.setValue(walkTime! * 60, forKey: "countDownDuration")
        
        // Set background color
        self.view.backgroundColor = colorize(0x6FD57F)
        
        // request user notification permissions        
        if  NSString(string: UIDevice.currentDevice().systemVersion).doubleValue >= 8.0 {
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound | UIUserNotificationType.Alert, categories: nil))
        }
        
        
    }
}
