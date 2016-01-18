//
//  MainTableViewController.swift
//  should I run? draft
//
//  Created by Roger Goldfinger on 7/11/14.
//  Copyright (c) 2014 Roger Goldfinger. All rights reserved.
//

import UIKit
import MapKit
import Foundation

@objc (MainTableViewController) class MainTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DataHandlerDelegate {

    var colorForChosenDestination = UIColor()
    
    let fileManager = SharedFileManager
    
    var timeoutTimer: NSTimer = NSTimer()
    
    // the timeout timer may be instantiated on a different thread than, 
    // say, an api request that would need to invalidate it.
    var timerInvalidated = false
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!

    override func viewWillAppear(animated: Bool) {
        DataHandler.instance.delegate = self
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting color scheme: https://kuler.adobe.com/Copy-of-Close-to-the-Garden-but-more-Teal-color-theme-4324985/
        
        self.view.backgroundColor = globalBackgroundColor
        self.tableView.backgroundColor = globalBackgroundColor
        self.emptyView.backgroundColor = globalBackgroundColor
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.setBackgroundImage(img, forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        
        self.checkEmptyState()
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let locations = fileManager.readFromDestinationsList()
        return locations.count
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let locations = fileManager.readFromDestinationsList()
        if editingStyle == .Delete {
            locations.removeObjectAtIndex(indexPath.row)
            fileManager.saveToDestinationsList(locations)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            self.checkEmptyState()
            self.tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlacePrototypeCell", forIndexPath: indexPath) as UITableViewCell
        let locations = fileManager.readFromDestinationsList()
        let row = indexPath.row

        if let location : AnyObject = locations[row] as AnyObject? {
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.textLabel!.text = location["name"] as? String
            var colorIndex = 0
            if let c = location["colorIndex"] as? Int {
                colorIndex = c
            }
            let color = colors[colorIndex % (colors.count - 1)]
            cell.textLabel?.textColor = color
            cell.accessoryView?.tintColor = color
            cell.backgroundColor = globalBackgroundColor
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 101
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let destinations = fileManager.readFromDestinationsList()
        let row = indexPath.row as Int
        
        if row < destinations.count {
            let chosenDestination = destinations[row]
            let colorIndex = chosenDestination["colorIndex"] as! Int
            self.colorForChosenDestination = colors[colorIndex]
            self.reorderDestinations(row)
            self.getDirectionsForDestination(chosenDestination)
        }
    }
    
    @IBAction func addDest(sender: AnyObject) {
        self.performSegueWithIdentifier("AddSegue", sender: self)
    }
    
    func reorderDestinations(selectedIndex: Int) {
        let savedDestinations = self.fileManager.readFromDestinationsList() as NSMutableArray
        let mostRecentDestination = savedDestinations[selectedIndex]
        savedDestinations.removeObjectAtIndex(selectedIndex)
        savedDestinations.insertObject(mostRecentDestination, atIndex: 0)
        self.fileManager.saveToDestinationsList(savedDestinations)
    }
    
    // Data fetching
    func getDirectionsForDestination(selectedDestination: AnyObject) {
        let locName = selectedDestination["name"] as! String
        let locLat = selectedDestination["latitude"] as! Float
        let locLong = selectedDestination["longitude"] as! Float

        DataHandler.instance.loadTrip(locName, lat: locLat, lon: locLong)
        
        self.performSegueWithIdentifier("LoadingSegue", sender: self)
        
        let timeoutText: Dictionary = ["titleString": "Time Out", "messageString": "Sorry! Your request took too long."]
        self.timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: Selector("onTimeout:"), userInfo: timeoutText, repeats: false)
        self.timerInvalidated = false
    }
    
    func cleanupLoading() {
        self.timerInvalidated = true
        self.timeoutTimer.invalidate()
        self.dismissViewControllerAnimated(false, completion: nil)
        DataHandler.instance.cancelLoad()
    }
    
    func handleDataSuccess() {
        self.cleanupLoading()
        self.performSegueWithIdentifier("ResultsSegue", sender: self)
    }
    
    func handleError(errorMessage: String) {
        self.cleanupLoading()
        let message = UIAlertController(title: "Oops!", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        message.addAction(OKAction)
        self.presentViewController(message, animated: true) {}
    }

    func onTimeout(timer: NSTimer) {
        self.cleanupLoading()
        if self.timerInvalidated == false {
            let message = UIAlertController(title: "Oops!", message: "Request timed out", preferredStyle: UIAlertControllerStyle.Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            message.addAction(OKAction)
            self.presentViewController(message, animated: true) {}
        }
    }
    
    func checkEmptyState() {
        let locations = fileManager.readFromDestinationsList()
        if locations.count == 0 {
            self.emptyView.hidden = false
            self.tableView.backgroundView = self.emptyView
        } else {
            self.emptyView.hidden = true
            self.tableView.backgroundView = nil
        }
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            apiController.instance.logApiResponse()
        }
    }
    
    // Navigation
    
    func unwindToList(segue:UIStoryboardSegue)  {
        // data may have updated
        self.checkEmptyState()
        self.tableView.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "LoadingSegue" {
            let dest: LoadingViewController = segue.destinationViewController as! LoadingViewController
            dest.backgroundColor = self.colorForChosenDestination
        }
    }
}
