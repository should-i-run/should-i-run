//
//  AddAlarmViewController.swift
//  Should I Run
//
//  Created by Kyle Craft on 7/17/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import UIKit

class AddAlarmViewController: UIViewController {
    
    @IBOutlet var alarmPicker: UIDatePicker
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alarmPicker.setValue(300, forKey: "countDownDuration")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func setAlarm(sender: AnyObject) {
        var localNotification:UILocalNotification = UILocalNotification()
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.alertBody = "Run!"
        localNotification.fireDate = NSDate(timeIntervalSinceNow: alarmPicker.countDownDuration)
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }

    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if sender.valueForKey("title") as NSString == "Save" {
            self.setAlarm(sender)
        }
    }
}
