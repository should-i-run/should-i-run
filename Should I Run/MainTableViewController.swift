//
//  MainTableViewController.swift
//  should I run? draft
//
//  Created by Roger Goldfinger on 7/11/14.
//  Copyright (c) 2014 Roger Goldfinger. All rights reserved.
//

import UIKit
import Foundation


@objc (MainTableViewController) class MainTableViewController: UITableViewController {
    

    var colors = [UIColor]()

    var locName:String = ""
    var locLat:Float = 0.0
    var locLong:Float = 0.0
    var colorForChosenLocation = UIColor()
    
    let fileManager = SharedFileManager
    

    override func viewDidLoad() {
      
        super.viewDidLoad()
        
        //setting color scheme: https://kuler.adobe.com/Copy-of-Close-to-the-Garden-but-more-Teal-color-theme-4324985/
        self.colors.append(colorize(0xFC5B3F))
        self.colors.append(colorize(0xFCB03C))
        self.colors.append(colorize(0x6FD57F))
        self.colors.append(colorize(0x068F86))
        self.colors.append(colorize(0x1A4F63))
        
        // Navigation and background colors
        self.navigationController?.navigationBar.tintColor = globalTintColor
        self.view.backgroundColor = globalBackgroundColor
        self.navigationController?.navigationBar.barStyle = globalBarStyle
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        //loc is locations plist as an array
        var locations = fileManager.readFromDestinationsList()
        
        return locations.count + 1
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        //loc is locations plist as an array
        var locations = fileManager.readFromDestinationsList()
        
        if indexPath.row == locations.count {
            return false
        }
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //loc is locations plist as an array
        //check if editing style is delete
        
        var locations = fileManager.readFromDestinationsList()
        
        if editingStyle == .Delete && indexPath.row != locations.count {
         
            //get the index row of the delete and compare with the number of objects in the plist
    
            locations.removeObjectAtIndex(indexPath.row)
            fileManager.saveToDestinationsList(locations)
            
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        
        let cell = tableView.dequeueReusableCellWithIdentifier("PlacePrototypeCell", forIndexPath: indexPath) as UITableViewCell
        
        
        
        var locations = fileManager.readFromDestinationsList()
      
        let row = indexPath.row

        // if the current row (zero indexed) is equal to that, we are on the add destination button
        if row == locations.count {
            

            
            cell.textLabel?.text = "add a destination"
            cell.backgroundColor = self.colors[4]
            cell.accessoryType = UITableViewCellAccessoryType.None
            
        //retrieve from the collection of objects with key "row number"
        } else if let location : AnyObject = locations[row] as AnyObject? {
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.textLabel?.text = location["name"] as NSString
            var index = row % self.colors.count
            cell.backgroundColor = self.colors[index]
        } else {
            cell.textLabel?.text = "Default"
            var index = row % self.colors.count
            cell.backgroundColor = self.colors[index]
        }
            
        

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 101
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var locations = fileManager.readFromDestinationsList()

        let row = indexPath.row as Int
        
        // if the current row (zero indexed) is equal to that, we are on the add destination button else we are on a location and can move on to the next step
        if row < locations.count {
            let locationSelected:AnyObject = locations[row]
            
            self.locName = locationSelected["name"] as NSString
            self.locLat = locationSelected["latitude"] as Float
            self.locLong = locationSelected["longitude"] as Float
            self.colorForChosenLocation = self.colors[row % self.colors.count]

            self.performSegueWithIdentifier("LoadingSegue", sender: self)

        } else {
            self.performSegueWithIdentifier("AddSegue", sender: self)
        }
        
        
    }
    
    func unwindToList(segue:UIStoryboardSegue)  {
        //reload the table on unwinding

        self.tableView.reloadData()
    
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "LoadingSegue" {

            var dest: LoadingViewController = segue.destinationViewController as LoadingViewController
            
            dest.locationName = self.locName
            //37.784923, -122.408396
            dest.destinationLatitude = self.locLat
            dest.destinationLongitude = self.locLong
            
            dest.backgroundColor = self.colorForChosenLocation
            
            
        }
    }
    
  
}
