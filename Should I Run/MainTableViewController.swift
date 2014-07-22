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
    
    var places:Array<Place> = []
    var colors:Array<UIColor> = []
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    var locName:String = ""
    var locLat:Float = 0.0
    var locLong:Float = 0.0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userDefaults.synchronize()
        
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
        let number : Int = userDefaults.integerForKey("num")
        return number + 1
    }
    
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        if indexPath.row == userDefaults.integerForKey("num") {
            return false
        }
        return true
    }
    
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        //check if editing style is delete
        var number : Int = userDefaults.integerForKey("num")
        
        if editingStyle == .Delete && indexPath.row != number {
            //get the index row of the delete and compare with the number of objects in the plist
           
            //if last element, just reduce count of number of objects by 1
            // else shift everything one step down

            if indexPath.row + 1 < number  {
                for index in indexPath.row...(number - 2) {
                    let location : AnyObject = userDefaults.objectForKey(String(index + 1))
                    userDefaults.setObject(location, forKey: String(index))
                    //we want to synchronize immediately so state is updated
                    userDefaults.synchronize()
                    
                }
            }
            //reduce count of objects by 1 and save it
            number = number - 1
            userDefaults.setInteger(number, forKey:"num")
            //remove from table view with animation
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        }
        
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PlacePrototypeCell", forIndexPath: indexPath) as UITableViewCell
        
        if let row = indexPath?.row {
            
            // 'num' is the number of user stored locations, 1 indexed.
            // if the current row (zero indexed) is equal to that, we are on the add destination button
            if row == userDefaults.integerForKey("num")  {
                cell.textLabel.text = "Add Destination"
                cell.backgroundColor = self.colors[4]
                cell.accessoryType = UITableViewCellAccessoryType.None
                
            //retrieve from the collection of objects with key "row number"
            } else if let location : AnyObject = userDefaults.objectForKey(String(row)) {
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
        

        let number : Int = userDefaults.integerForKey("num")
        let row = indexPath.row as Int
        
        // 'num' is the number of user stored locations, 1 indexed.
        // if the current row (zero indexed) is equal to that, we are on the add destination button
        if row < number {
            let location : AnyObject = userDefaults.objectForKey(String(indexPath.row))
            
            self.locName = location["name"] as NSString
            self.locLat = location["latitude"] as Float
            self.locLong = location["longitude"] as Float

            self.performSegueWithIdentifier("LoadingSegue", sender: self)

        } else {
            self.performSegueWithIdentifier("AddSegue", sender: self)
            let num = userDefaults.integerForKey("num")
            println("number of places before add: \(num)")
        }
        
        
    }
    
    func unwindToList(segue:UIStoryboardSegue)  {
        //reload the table on unwinding
        self.tableView.reloadData()
    
    }

    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        
        if segue.identifier == "LoadingSegue" {

            var dest: LoadingViewController = segue.destinationViewController as LoadingViewController
            
            dest.locationName = self.locName
            //37.784923, -122.408396
            dest.latDest = self.locLat
            dest.lngDest = self.locLong
            
            
        } else if segue.identifier == "AddSegue" {
           //do something
        }
        
    }
    
  
}