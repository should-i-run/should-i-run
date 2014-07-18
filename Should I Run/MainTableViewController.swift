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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.colors.append(UIColor(red: CGFloat(223.0/255), green: CGFloat(73.0/255), blue: CGFloat(73.0/255), alpha: CGFloat(1.0)))
        self.colors.append(UIColor(red: CGFloat(226.0/255), green: CGFloat(122.0/255), blue: CGFloat(63.0/255), alpha: CGFloat(1.0)))
        self.colors.append(UIColor(red: CGFloat(239.0/255), green: CGFloat(201.0/255), blue: CGFloat(76.0/255), alpha: CGFloat(1.0)))
        self.colors.append(UIColor(red: CGFloat(69.0/255), green: CGFloat(178.0/255), blue: CGFloat(157.0/255), alpha: CGFloat(1.0)))
        self.colors.append(UIColor(red: CGFloat(51.0/255), green: CGFloat(77.0/255), blue: CGFloat(92.0/255), alpha: CGFloat(1.0)))
        

         self.navigationItem.leftBarButtonItem = self.editButtonItem()
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
        return number
    }
    
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        //check if editing style is delete
        if editingStyle == .Delete {
            //get the index row of the delete and compare with the number of objects in the plist
           var number : Int = userDefaults.integerForKey("num")
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
        let CellIdentifier = "PlacePrototypeCell"
        let cell = tableView.dequeueReusableCellWithIdentifier("PlacePrototypeCell", forIndexPath: indexPath) as UITableViewCell
        
        
        if let row = indexPath?.row {
            //retrieve from the collection of objects with key "row number"
                if let location : AnyObject = userDefaults.objectForKey(String(row)) {
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
    
    func unwindToList(segue:UIStoryboardSegue)  {
        //reload the table on unwinding
            self.tableView.reloadData()
    
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        
        //kyle's API = AIzaSyB9JV82Cy-GFPTAbYy3HgfZOGT75KVp-dg
        //Neil's API = AIzaSyChLClMFZtSSmUSiP9fM333RLGms0w5ogc

       
    }

    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        
        if segue.identifier == "LoadingSegue" {

//            var dest: LoadingViewController = segue.destinationViewController as LoadingViewController

//            var label: UILabel = sender.textLabel as UILabel //extra step to typecast so that we can get the text property.
//            dest.locationName = "hey"
//            dest.lat = label.lat???
//            dest.lng = label.lng???
            
            
        } else if segue.identifier == "AddSegue" {
           //do something
        }
        
    }
    
  
}