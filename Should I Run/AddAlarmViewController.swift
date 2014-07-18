//
//  AddAlarmViewController.swift
//  Should I Run
//
//  Created by Kyle Craft on 7/17/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import UIKit
import AudioToolbox

class AddAlarmViewController: UIViewController {

    @IBOutlet var alarmDatePicker: UIDatePicker
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alarmDatePicker.setValue(500, forKey: "countDownDuration")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveAlarm(sender: UIButton) {
        var localNotification:UILocalNotification = UILocalNotification()
        localNotification.soundName = UILocalNotificationDefaultSoundName
        
        localNotification.alertBody = "Run!"
        localNotification.fireDate = NSDate(timeIntervalSinceNow: alarmDatePicker.countDownDuration)
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }


}
