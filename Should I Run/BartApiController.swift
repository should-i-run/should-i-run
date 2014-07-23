//
//  BartApiController.swift
//  Should I Run
//
//  Created by LM on 7/17/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import UIKit

// Create BART API protocol that needs to be adhered to
protocol BartApiControllerDelegate {
    // Actual implementation of methods needs to be written inside the class using this protocol
    func didReceiveBartResults(results: [(String, Int)])
}

class BartApiController: NSObject , NSURLConnectionDelegate{

    // Create delegate
    // Can be any class, as long as it adheres to BartApiControllerProtocol (by defining didReceiveBartResults in this case)
    var delegate: BartApiControllerDelegate?
    

    func searchBartFor(searchAbbr: String) {

        
        // Fetch information for the BART api and convert the returned XML into a dictionary
        let url = NSURL(string: "http://api.bart.gov/api/etd.aspx?cmd=etd&orig=" + searchAbbr + "&key=ZELI-U2UY-IBKQ-DT35")

        var request = NSURLRequest(URL: url)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                self.hanldeConnectionCallbackWithData(data, andError: error)
            })

    }
    
    func hanldeConnectionCallbackWithData(data:NSData?, andError error:NSError?){
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        let html = NSString(data: data, encoding: NSUTF8StringEncoding)
        
        let parsed: NSDictionary = XMLReader.dictionaryForXMLString(html, error: nil)
        
        // Trim off unneeded data inside the dictionary
        let stations: NSDictionary = parsed.objectForKey("root").objectForKey("station") as NSDictionary
        
        // Create an array of tuples to store our destination stations (termini) and their estimated arrival time to our closest BART  station
        var allResults: [(String, Int)] = []
        
        // Iterate over our stations
        for aStation in stations {
            
            if (aStation.key as String == "etd") {
                
                
                // Check if stations are in an Array, or if there is only one station, a Dictionary
                // If Dictionary, insert into an Array to iterate over
                var etdList:[NSDictionary] = []
                
                if let ival:[NSDictionary] = aStation.value as? [NSDictionary] {
                    etdList += ival
                    
                } else if let ival:NSDictionary = aStation.value as? NSDictionary {
                    etdList.append(ival)
                    
                }
                
                
                
                
                for stationItem in etdList as [NSDictionary] {
                    var abbr = stationItem["abbreviation"] as NSDictionary
                    
                    // same issue for departures
                    // Check if departures are in an Array, or if there is only one station, a Dictionary
                    // If Dictionary, insert into an Array to iterate over
                    
                    var estimateList:[NSDictionary] = []
                    
                    if let estimate:[NSDictionary] = stationItem["estimate"] as? [NSDictionary]{
                        estimateList += estimate
                        
                    } else if let estimate:NSDictionary = stationItem["estimate"] as? NSDictionary {
                        estimateList.append(estimate)
                        
                    }
                    
                    for estimateItem in estimateList as [AnyObject] {
                        var estimateMin = estimateItem["minutes"] as NSDictionary
                        
                        // Create the terminus and estimated arrival tuple and push into our results
                        var myTuple: (String, Int) = (abbr["text"] as String, estimateMin["text"].integerValue)
                        allResults += myTuple
                    }
                }
            }
        }
        
        // Sort the tuple array of termini and estimated arrival in ascending order
        allResults.sort{$0.1 < $1.1}
        
        self.delegate?.didReceiveBartResults(allResults)

        
    }
}
    