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

class BartApiController: NSObject {

    // Create delegate
    // Can be any class, as long as it adheres to BartApiControllerProtocol (by defining didReceiveBartResults in this case)
    var delegate: BartApiControllerDelegate?
    

    func searchBartFor(searchAbbr: String) {

        
        // Fetch information for the BART api and convert the returned XML into a dictionary
        let url = NSURL(string: "http://api.bart.gov/api/etd.aspx?cmd=etd&orig=" + searchAbbr + "&key=ZELI-U2UY-IBKQ-DT35")
        let data = NSMutableData.dataWithContentsOfURL(url, options: NSDataReadingOptions.DataReadingUncached, error: nil)
        let html = NSString(data: data, encoding: NSUTF8StringEncoding)
        let parsed: NSDictionary = XMLReader.dictionaryForXMLString(html, error: nil)
        
        // Trim off unneeded data inside the dictionary
        let stations: NSDictionary = parsed.objectForKey("root").objectForKey("station") as NSDictionary
        
        // Create an array of tuples to store our destination stations (termini) and their estimated arrival time to our closest BART  station
        var allResults: [(String, Int)] = []

        // Iterate over our stations
        for item in stations {
            if (item.key as String == "etd") {
                // We need to check if one result or multiple results exist. If we have multiple results, we'll do a loop. Otherwise, we can access terminus abbreviation and estimated time directly
                if (item.value["abbreviation"]) {
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
        

        
        self.delegate?.didReceiveBartResults(allResults)
        

    }
    
    
    
}
    