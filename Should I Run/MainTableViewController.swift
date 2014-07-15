//
//  MainTableViewController.swift
//  should I run? draft
//
//  Created by Roger Goldfinger on 7/11/14.
//  Copyright (c) 2014 Roger Goldfinger. All rights reserved.
//

import UIKit


@objc (MainTableViewController) class MainTableViewController: UITableViewController {
    
    var places:Array<Place> = []
    var colors:Array<UIColor> = []
     let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        
//        self.tableView.allowsMultipleSelectionDuringEditing = false;
        super.viewDidLoad()

        
        self.colors.append(UIColor(red: CGFloat(223.0/255), green: CGFloat(73.0/255), blue: CGFloat(73.0/255), alpha: CGFloat(1.0)))
        self.colors.append(UIColor(red: CGFloat(226.0/255), green: CGFloat(122.0/255), blue: CGFloat(63.0/255), alpha: CGFloat(1.0)))
        self.colors.append(UIColor(red: CGFloat(239.0/255), green: CGFloat(201.0/255), blue: CGFloat(76.0/255), alpha: CGFloat(1.0)))
        self.colors.append(UIColor(red: CGFloat(69.0/255), green: CGFloat(178.0/255), blue: CGFloat(157.0/255), alpha: CGFloat(1.0)))
        self.colors.append(UIColor(red: CGFloat(51.0/255), green: CGFloat(77.0/255), blue: CGFloat(92.0/255), alpha: CGFloat(1.0)))
        
      
      
       
        
//        userDefaults.setObject(["name": "Stanford", "latitude": 20.31, "longitude": 60.40], forKey: "1")
//        
//        userDefaults.setObject(["name": "Mission", "latitude": 37.31, "longitude": -12.40], forKey: "2")
//        let number = 2
//        userDefaults.setInteger(number, forKey:"num")
//        userDefaults.synchronize()
      
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//         self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let CellIdentifier = "PlacePrototypeCell"
        let cell = tableView.dequeueReusableCellWithIdentifier("PlacePrototypeCell", forIndexPath: indexPath) as UITableViewCell
        
        
        if let row = indexPath?.row {
                if let location : AnyObject = userDefaults.objectForKey(String(row+1)) {
                    cell.textLabel.text = location["name"] as NSString
                    println(location["name"])
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
        var source = segue.sourceViewController as AddViewController
        
        if let item = source.place? {
            self.places.append(item)
            self.tableView.reloadData()
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        
        if segue.identifier == "ResultsSegue" {
            var dest: ResultTableViewController = segue.destinationViewController as ResultTableViewController

            var label: UILabel = sender.textLabel as UILabel //extra step to typecast so that we can get the text property.
            dest.locationName = label.text
        } else if segue.identifier == "AddSegue" {

        }
        
        
        
        
    }
    
    
}