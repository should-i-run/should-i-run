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

        var time = Int(NSDate().timeIntervalSince1970)

    
        var url = NSURL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=37.784465,-122.408761&destination=37.872356,-122.276810&key=AIzaSyB9JV82Cy-GFPTAbYy3HgfZOGT75KVp-dg&departure_time=\(time)&mode=transit&alternatives=true")
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {
            (data, response, error) in
            
         var dataFromGoogle = NSString(data: data, encoding: NSUTF8StringEncoding)
            if error {
               println("Data Retrieval Error!!",error)
            }
            
            

        let jsonData: NSData = data
            
        let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            
            
            self.convertGoogleToBart(jsonDict)
        }
        
        task.resume()
    }
    
    
    
    func convertGoogleToBart(goog: NSDictionary) ->  Array<String> {
        var results :Array<String> = []
       
        var foundWalking : Bool = false
        var i:Int  = 0
        var name1:String = ""
        var fname1:String = ""
        
    
        
        var inter : NSArray = goog.objectForKey("routes") as NSArray
        

        var inter2 : NSArray = inter[0].objectForKey("legs") as NSArray

        var steps : NSArray = inter2[0].objectForKey("steps") as NSArray


        while(!foundWalking){
            if steps[i].objectForKey("travel_mode") as String == "WALKING" {
                foundWalking = true
                
                name1 = steps[i].objectForKey("html_instructions") as String
                fname1 = name1.substringFromIndex(7).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
              

//                    println("Only Station 1 name is \(fname1)")
                var stn1 = bartLookup[fname1]
//                println("Bart Lookup for Station 1 is \(stn1)")
                
                var distance = steps[i].objectForKey("distance") as NSDictionary
    
                results.append(String(distance["value"].intValue))
                results.append(stn1!.uppercaseString)
                
            } else if i == steps.count {
                foundWalking = true
                println("No Valid Transit Directions")
            }else {
                i++
            }
        }
        
        i++
        
        var fname2:String = ""
        var name2:String = steps[i].objectForKey("html_instructions") as String
        
        fname2 = name2.substringFromIndex(19).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
//         println("Only Station 2 name is \(fname2)")
        
        var stn2 = bartLookup[fname2];
        println("Bart Lookup for Station 2 is \(stn2)")

        results.append(stn2!.uppercaseString)
        
        
        
        i = 0;
        var k: Int = 1

        while k < inter.count {

          var inter2 = inter[k].objectForKey("legs") as NSArray
          var steps : NSArray = inter2[0].objectForKey("steps") as NSArray

          foundWalking = false;
          
          while(!foundWalking){
            if (steps[i]? && steps[i].objectForKey("travel_mode")? && steps[i].objectForKey("travel_mode") as String == "WALKING"){
                foundWalking = true
            } else if i+1 >= steps.count {
                foundWalking = true
            } else {
                i++
            }
          }
          
         i++
            if i < steps.count {
                name2 = steps[i].objectForKey("html_instructions") as String
                name2 = name2.substringFromIndex(19)
            }
            
            if bartLookup[name2]{
                stn2 = bartLookup[name2]
                results.append(stn2!.uppercaseString)
            }
        k++
        
        }
        println(results)
        return results
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        
        if segue.identifier == "ResultsSegue" {

            var dest: ResultTableViewController = segue.destinationViewController as ResultTableViewController

            var label: UILabel = sender.textLabel as UILabel //extra step to typecast so that we can get the text property.
            if label.text == "Add Destination" {
                println("Reached here")
//                return
            }
            dest.locationName = label.text
        } else if segue.identifier == "AddSegue" {
           //do something
        }
        
    }
    
  
}