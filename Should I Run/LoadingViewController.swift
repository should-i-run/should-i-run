//
//  LoadingViewController.swift
//  Should I Run
//
//  Created by Roger Goldfinger on 7/17/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController, BartApiControllerDelegate {
    var locationName:String?
    
    var bartResults: [(String, Int)]?
    
    // Create controller to handle BART API queries
    var bartApiController: BartApiController = BartApiController()
    

    override func viewDidLoad() {
        
        resultsFromGoogle()
    }

    func resultsFromGoogle() {
        
        // Set delegate to this class (we are delegating the controller's actions to this class)
        self.bartApiController.delegate = self
        
        // Call didReceiveBartResults method below via delegate relationship
        self.bartApiController.searchBartFor("cols")
        
        println(self.bartResults)

        
        resultsFromBart()
    }
    
    
    func resultsFromBart() {
 
      
        self.performSegueWithIdentifier("ResultsSegue", sender: self)
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!)  {
        println("preparing for segue")
        var destinationController = segue.destinationViewController as ResultViewController
        destinationController.distance = 1000
        destinationController.departureStationName = "Powell Street"
        destinationController.departures = [("PITT", 3), ("DBLN", 6), ("FRANCE", 12), ("London", 24), ("Kiev", 30)]
        
    }

    
    // Conform to BartApiControllerProtocol by implementing this method
    func didReceiveBartResults(results: [(String, Int)]) {
        self.bartResults = results
        
        dispatch_async(dispatch_get_main_queue(), {
            // Add any code that should run asyncronously while waiting for data
            // i.e. "to move back in to the main thread, and reload the table view."
            })
    }
    
}
