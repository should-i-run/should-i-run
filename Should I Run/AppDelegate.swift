//
//  AppDelegate.swift
//  should I run? draft
//
//  Created by Roger Goldfinger on 7/11/14.
//  Copyright (c) 2014 Roger Goldfinger. All rights reserved.
//

import UIKit


// Main Application
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIAlertViewDelegate {
                            
    var window: UIWindow?
    
    let locationManager = SharedUserLocation


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        
        
        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
        var alert = UIAlertView(title:"Reminder", message: notification.alertBody, delegate: self, cancelButtonTitle: "OK")
        alert.show();

    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        self.locationManager.locationManager.stopUpdatingLocation()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.locationManager.locationManager.stopUpdatingLocation()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        self.locationManager.locationManager.startUpdatingLocation()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.locationManager.locationManager.startUpdatingLocation()
        
        //request GPS authorization on iOS 8
        if  NSString(string: UIDevice.currentDevice().systemVersion).doubleValue >= 8.0 {
            self.locationManager.locationManager.requestWhenInUseAuthorization()
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

