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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alarmPicker.setValue(walkTime! * 60, forKey: "countDownDuration")
        
        // Set background color
        self.view.backgroundColor = colorize(0x6FD57F)

    }
    
    @IBAction func setAlarm(sender: AnyObject) {
        var localNotification:UILocalNotification = UILocalNotification()
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.alertBody = "Should I Run?"
        localNotification.fireDate = NSDate(timeIntervalSinceNow: alarmPicker.countDownDuration)
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let title = sender?.valueForKey("title") as? NSString {
            if title == "save" {
                self.setAlarm(sender!)
            }
        }
    }
}
