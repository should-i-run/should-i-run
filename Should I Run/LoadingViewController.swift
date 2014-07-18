//
//  LoadingViewController.swift
//  Should I Run
//
//  Created by Roger Goldfinger on 7/17/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController, BartApiControllerDelegate, GoogleAPIControllerProtocol {
    var locationName:String?
    var lat : Float?
    var lng : Float?
    
    var bartResults: [(String, Int)]?
    var googleResults : [String]?
    
    var distanceToStart : Int = 0
    var departureStationName: String = ""
    
    // Create controller to handle BART API queries
    var bartApiController: BartApiController = BartApiController()
    
    //Create controller to handle Google API queries
    var gApi : GoogleApiController = GoogleApiController()
    

    override func viewDidLoad(){
        self.gApi.delegate = self
        self.bartApiController.delegate = self
        

        //Fetching data from Google and parsing it
        println("\(self.locationName) and \(self.lat)")
        self.gApi.fetchGoogleData(self.lat!,long: self.lng!)

    }
    
    func didReceiveGoogleResults(results: Array<String>) {
        self.distanceToStart = results[0].toInt()!
        self.departureStationName = results[1]
        self.bartApiController.searchBartFor(self.departureStationName)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!)  {

        var destinationController = segue.destinationViewController as ResultViewController
        destinationController.distance = self.distanceToStart
        destinationController.departureStationName = self.departureStationName
//        destinationController.departures = self.bartResults
    }

    
    // Conform to BartApiControllerProtocol by implementing this method
    func didReceiveBartResults(results: [(String, Int)]) {
        println("Gotback from bart")
        println("Bart Results are \(results)")
        self.bartResults = results
//        self.performSegueWithIdentifier("ResultsSegue", sender: self)
        
        

    }
    
    
    
}
