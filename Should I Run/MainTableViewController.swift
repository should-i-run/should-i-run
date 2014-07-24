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
    

    var colors:Array<UIColor> = []

    var locName:String = ""
    var locLat:Float = 0.0
    var locLong:Float = 0.0
    

    override func viewDidLoad() {
      
        super.viewDidLoad()
        
        //setting color scheme
        self.colors.append(UIColor(red: CGFloat(239.0/255), green: CGFloat(201.0/255), blue: CGFloat(76.0/255), alpha: CGFloat(1.0)))
        self.colors.append(UIColor(red: CGFloat(69.0/255), green: CGFloat(178.0/255), blue: CGFloat(157.0/255), alpha: CGFloat(1.0)))
        self.colors.append(UIColor(red: CGFloat(223.0/255), green: CGFloat(73.0/255), blue: CGFloat(73.0/255), alpha: CGFloat(1.0)))
        self.colors.append(UIColor(red: CGFloat(226.0/255), green: CGFloat(122.0/255), blue: CGFloat(63.0/255), alpha: CGFloat(1.0)))
        self.colors.append(UIColor(red: CGFloat(51.0/255), green: CGFloat(77.0/255), blue: CGFloat(92.0/255), alpha: CGFloat(1.0)))
        

        // uncomment this line to get the edit button back
        // self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        // Navigation and background colors
        self.navigationController.navigationBar.tintColor = globalTintColor
        self.view.backgroundColor = globalBackgroundColor
        self.navigationController.navigationBar.barStyle = globalBarStyle
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
        var loc = NSMutableArray(contentsOfFile: NSBundle.mainBundle().pathForResource("Locations", ofType: "plist"))
        return loc.count + 1
    }
    
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        //loc is locations plist as an array
        var loc = NSMutableArray(contentsOfFile: NSBundle.mainBundle().pathForResource("Locations", ofType: "plist"))
        if indexPath.row == loc.count {
            return false
        }
        return true
    }
    
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        //loc is locations plist as an array
        //check if editing style is delete
        var loc = NSMutableArray(contentsOfFile: NSBundle.mainBundle().pathForResource("Locations", ofType: "plist"))
        
        if editingStyle == .Delete && indexPath.row != loc.count {
         
            //get the index row of the delete and compare with the number of objects in the plist
    
            loc.removeObjectAtIndex(indexPath.row)
            loc.writeToFile(NSBundle.mainBundle().pathForResource("Locations", ofType: "plist"), atomically: false)
            
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PlacePrototypeCell", forIndexPath: indexPath) as UITableViewCell
        var loc = NSMutableArray(contentsOfFile: NSBundle.mainBundle().pathForResource("Locations", ofType: "plist"))
        if let row = indexPath?.row {

            // if the current row (zero indexed) is equal to that, we are on the add destination button
            if row == loc.count {
                
                cell.textLabel.text = "Add Destination"
                cell.backgroundColor = self.colors[4]
                cell.accessoryType = UITableViewCellAccessoryType.None
                
            //retrieve from the collection of objects with key "row number"
            } else if let location : AnyObject = loc[row] {
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell.textLabel.text = location["name"] as NSString
                var index = row % self.colors.count
                cell.backgroundColor = self.colors[index]
            } else {
                cell.textLabel.text = "Default"
                var index = row % self.colors.count
                cell.backgroundColor = self.colors[index]
            }
            
        }

        return cell
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        var loc = NSMutableArray(contentsOfFile: NSBundle.mainBundle().pathForResource("Locations", ofType: "plist"))
        let row = indexPath.row as Int
        
        // if the current row (zero indexed) is equal to that, we are on the add destination button else we are on a location and can move on to the next step
        if row < loc.count {
            let locationSelected:AnyObject = loc[row]
            
            self.locName = locationSelected["name"] as NSString
            self.locLat = locationSelected["latitude"] as Float
            self.locLong = locationSelected["longitude"] as Float

            self.performSegueWithIdentifier("LoadingSegue", sender: self)

        } else {
            self.performSegueWithIdentifier("AddSegue", sender: self)
        }
        
        
    }
    
    func unwindToList(segue:UIStoryboardSegue)  {
        //reload the table on unwinding
        var loc = NSMutableArray(contentsOfFile: NSBundle.mainBundle().pathForResource("Locations", ofType: "plist"))
     
        self.tableView.reloadData()
    
    }

    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        
        if segue.identifier == "LoadingSegue" {

            var dest: LoadingViewController = segue.destinationViewController as LoadingViewController
            
            dest.locationName = self.locName
            //37.784923, -122.408396
            dest.destinationLatitude = self.locLat
            dest.destinationLongitude = self.locLong
            
            
        }
    }
    
  
}
