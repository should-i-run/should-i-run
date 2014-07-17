//
//  LoadingViewController.swift
//  Should I Run
//
//  Created by Roger Goldfinger on 7/17/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    var locationName:String?
    
    override func viewDidLoad() {
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

}
