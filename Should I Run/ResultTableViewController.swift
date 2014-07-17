//
//  ResultTableViewController.swift
//  should I run? draft
//
//  Created by Roger Goldfinger on 7/11/14.
//  Copyright (c) 2014 Roger Goldfinger. All rights reserved.
//

import UIKit

class ResultTableViewController: UITableViewController {
    
    var locationName: String?
    
    var senderUILabel: UILabel?

    @IBOutlet var destinationCell : UITableViewCell
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.destinationCell.textLabel.text = "You're going to " + self.locationName!

        // Fetch information for the BART api and convert the returned XML into a dictionary
        var url = NSURL(string: "http://api.bart.gov/api/etd.aspx?cmd=etd&orig=cols&key=ZELI-U2UY-IBKQ-DT35")
        var data = NSMutableData.dataWithContentsOfURL(url, options: NSDataReadingOptions.DataReadingUncached, error: nil)
        let html = NSString(data: data, encoding: NSUTF8StringEncoding)
        var parsed: NSDictionary = XMLReader.dictionaryForXMLString(html, error: nil)

        // Trim off unneeded data inside the dictionary
        var stations: NSDictionary = parsed.objectForKey("root").objectForKey("station") as NSDictionary
        
        // Create an array of tuples to store our destination stations (termini) and their estimated arrival time to our closest BART  station
        var allResults: [(String, Int)] = []
        
        // Iterate over our stations
        for item in stations {
            if (item.key as NSString == "etd") {
                // We need to check if one result or multiple results exist. If we have multiple results, we'll do a loop. Otherwise, we can access terminus abbreviation and estimated time directly
                if (item.value["abbreviation"]) {
                    var myTuple: (String, Int)
                    var abbr = item.value["abbreviation"] as NSDictionary
                    for estimateItem in item.value["estimate"] as [AnyObject] {
                        var estimateMin = estimateItem["minutes"] as NSDictionary
                        
                        // Create the terminus and estimated arrival tuple and push into our results
                        var myTuple: (String, Int) = (abbr["text"] as String, estimateMin["text"].integerValue)
                        allResults += myTuple
                    }

                } else {
                    for stationItem in item.value as [AnyObject] {
                        var abbr = stationItem["abbreviation"] as NSDictionary
                        for estimateItem in stationItem["estimate"] as [AnyObject] {
                            var estimateMin = estimateItem["minutes"] as NSDictionary

                            // Create the terminus and estimated arrival tuple and push into our results
                            var myTuple: (String, Int) = (abbr["text"] as String, estimateMin["text"].integerValue)
                            allResults += myTuple
                        }
                    }
                }
            }
        }

        // Sort the tuple array of termini and estimated arrival in ascending order

        allResults.sort{$0.1 < $1.1}
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: false)
//    }

    // #pragma mark - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
//        // #warning Potentially incomplete method implementation.
//        // Return the number of sections.
//        return 0
//    }

//    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete method implementation.
//        // Return the number of rows in the section.
//        return 0
//    }

    /*
    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

         Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView?, canEditRowAtIndexPath indexPath: NSIndexPath?) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView?, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath?) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView?, moveRowAtIndexPath fromIndexPath: NSIndexPath?, toIndexPath: NSIndexPath?) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView?, canMoveRowAtIndexPath indexPath: NSIndexPath?) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */


    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject?) {
//        // Get the new view controller using [segue destinationViewController].
//        // Pass the selected object to the new view controller.
//        var controller = segue.destinationViewController as ResultTableViewController
//        controller.locationName = ""
//    }


}
