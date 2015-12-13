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

@objc (MainTableViewController) class MainTableViewController: UITableViewController, DataHandlerDelegate {
    var colors = [UIColor]()

    var colorForChosenLocation = UIColor()
    
    let fileManager = SharedFileManager
    
    var timeoutTimer: NSTimer = NSTimer()
    
    override func viewWillAppear(animated: Bool) {
        DataHandler.instance.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting color scheme: https://kuler.adobe.com/Copy-of-Close-to-the-Garden-but-more-Teal-color-theme-4324985/
        self.colors.append(colorize(0xFC5B3F))
        self.colors.append(colorize(0xFCB03C))
        self.colors.append(colorize(0x6FD57F))
        self.colors.append(colorize(0x068F86))
        self.colors.append(colorize(0x1A4F63))
        
        self.view.backgroundColor = globalBackgroundColor
    }
    
    override func viewDidAppear(animated: Bool) {
        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.setBackgroundImage(img, forBarMetrics: UIBarMetrics.Default)
        super.viewDidAppear(animated)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        //loc is locations plist as an array
        let locations = fileManager.readFromDestinationsList()
        return locations.count + 2
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        //loc is locations plist as an array
        let locations = fileManager.readFromDestinationsList()
        
        if indexPath.row == locations.count || indexPath.row == locations.count + 1 {
            return false
        }
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let locations = fileManager.readFromDestinationsList()
        if editingStyle == .Delete && indexPath.row != locations.count {
            //get the index row of the delete and compare with the number of objects in the plist
            locations.removeObjectAtIndex(indexPath.row)
            fileManager.saveToDestinationsList(locations)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlacePrototypeCell", forIndexPath: indexPath) as UITableViewCell
        let locations = fileManager.readFromDestinationsList()
        let row = indexPath.row

        //row is not zero indexed, locations is
        if row == locations.count {
            cell.textLabel!.text = "+ add destination"
            cell.backgroundColor = self.colors[4]
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            
        } else if row == locations.count + 1 {
            cell.textLabel!.text = "instructions"
            cell.backgroundColor = colorize(0x068F86)
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        //retrieve from the collection of objects with key "row number"
        } else if let location : AnyObject = locations[row] as AnyObject? {
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.textLabel!.text = location["name"] as? String
            let index = row % self.colors.count
            cell.backgroundColor = self.colors[index]
        } else {
            cell.textLabel!.text = "Default"
            let index = row % self.colors.count
            cell.backgroundColor = self.colors[index]
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 101
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let locations = fileManager.readFromDestinationsList()
        let row = indexPath.row as Int
        
        // if the current row (zero indexed) is equal to that, we are on the add destination button else we are on a location and can move on to the next step
        if row < locations.count {
            self.colorForChosenLocation = self.colors[row % self.colors.count]
            self.fetchData(locations[row])
        } else if row == locations.count {
            self.performSegueWithIdentifier("AddSegue", sender: self)
        } else if row == locations.count + 1 {
            self.performSegueWithIdentifier("InstructionsSegue", sender: self)
        }
    }
    
    // Data fetching
    func fetchData(selectedLocation: AnyObject) {
        let locName = selectedLocation["name"] as! String
        let locLat = selectedLocation["latitude"] as! Float
        let locLong = selectedLocation["longitude"] as! Float

        DataHandler.instance.loadTrip(locName, lat: locLat, lon: locLong)
        
        self.performSegueWithIdentifier("LoadingSegue", sender: self)
        
        let timeoutText: Dictionary = ["titleString": "Time Out", "messageString": "Sorry! Your request took too long."]
        self.timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: Selector("onTimeout:"), userInfo: timeoutText, repeats: false)
    }
    
    func cleanupLoading() {
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
        let message = UIAlertController(title: "Oops!", message: "Request timed out", preferredStyle: UIAlertControllerStyle.Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        message.addAction(OKAction)
        self.presentViewController(message, animated: true) {}
    }
    
    // Navigation
    
    func unwindToList(segue:UIStoryboardSegue)  {
        // data may have updated
        self.tableView.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "LoadingSegue" {
            let dest: LoadingViewController = segue.destinationViewController as! LoadingViewController
            dest.backgroundColor = self.colorForChosenLocation
        }
    }
}
