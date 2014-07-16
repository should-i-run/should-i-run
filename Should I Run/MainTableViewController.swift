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
        super.viewDidLoad()
        
        var testXMLString = "<items><item id=\"0001\" type=\"donut\"><name>Cake</name><ppu>0.55</ppu><batters><batter id=\"1001\">Regular</batter><batter id=\"1002\">Chocolate</batter><batter id=\"1003\">Blueberry</batter></batters><topping id=\"5001\">None</topping><topping id=\"5002\">Glazed</topping><topping id=\"5005\">Sugar</topping></item></items>";

        
        var parsed:NSDictionary = XMLReader.dictionaryForXMLString(testXMLString, error: nil)
        
        println(parsed)
        
        
        var url = NSURL(string: "http://api.bart.gov/api/etd.aspx?cmd=etd&orig=ncon&key=ZELI-U2UY-IBKQ-DT35")

        
        var data = NSMutableData.dataWithContentsOfURL(url, options: NSDataReadingOptions.DataReadingUncached, error: nil)
        println(data)
        

        
        let html = NSString(data: data, encoding: NSUTF8StringEncoding) as NSObject
        println(html)
        





        
        self.colors.append(UIColor(red: CGFloat(223.0/255), green: CGFloat(73.0/255), blue: CGFloat(73.0/255), alpha: CGFloat(1.0)))
        self.colors.append(UIColor(red: CGFloat(226.0/255), green: CGFloat(122.0/255), blue: CGFloat(63.0/255), alpha: CGFloat(1.0)))
        self.colors.append(UIColor(red: CGFloat(239.0/255), green: CGFloat(201.0/255), blue: CGFloat(76.0/255), alpha: CGFloat(1.0)))
        self.colors.append(UIColor(red: CGFloat(69.0/255), green: CGFloat(178.0/255), blue: CGFloat(157.0/255), alpha: CGFloat(1.0)))
        self.colors.append(UIColor(red: CGFloat(51.0/255), green: CGFloat(77.0/255), blue: CGFloat(92.0/255), alpha: CGFloat(1.0)))
        

//        userDefaults.setObject(["name": "Stanford", "latitude": 20.31, "longitude": 60.40], forKey: "0")
//        
//        userDefaults.setObject(["name": "Mission", "latitude": 37.31, "longitude": -12.40], forKey: "1")
//        let number = 2
//        userDefaults.setInteger(number, forKey:"num")
//        userDefaults.synchronize()
      
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
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
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        
        if segue.identifier == "ResultsSegue" {
            var dest: ResultTableViewController = segue.destinationViewController as ResultTableViewController

            var label: UILabel = sender.textLabel as UILabel //extra step to typecast so that we can get the text property.
            dest.locationName = label.text
        } else if segue.identifier == "AddSegue" {



           //do something

        }
        
    }
    
  
}