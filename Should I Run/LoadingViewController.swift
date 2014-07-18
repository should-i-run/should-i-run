//
//  LoadingViewController.swift
//  Should I Run
//
//  Created by Roger Goldfinger on 7/17/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import UIKit
import MapKit

class LoadingViewController: UIViewController, BartApiControllerDelegate, GoogleAPIControllerProtocol, CLLocationManagerDelegate  {
    var locationName:String?
    var latDest : Float?
    var lngDest : Float?
    
    var latStart : Float?
    var lngStart : Float?
    
    
    var bartResults: [(String, Int)]?
    var googleResults : [String]?
    
    var distanceToStart : Int = 0
    var departureStationName: String = ""
    
    let notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()
    let mainQueue: NSOperationQueue = NSOperationQueue.mainQueue()
    let locationManager = SharedUserLocation
    
    // Create controller to handle BART API queries
    var bartApiController: BartApiController = BartApiController()
    
    //Create controller to handle Google API queries
    var gApi : GoogleApiController = GoogleApiController()
    var googleCalled = false
    

    override func viewDidLoad(){
        
        //set this class as the delegate for the api controllers
        self.gApi.delegate = self
        self.bartApiController.delegate = self
        
        //Fetching data from Google and parsing it
        if let loc2d: CLLocationCoordinate2D =  self.locationManager.currentLocation2d {
            
            println("Current location is \(loc2d)")
            
            self.latStart = Float(loc2d.latitude)
            self.lngStart = Float(loc2d.longitude)
            self.gApi.fetchGoogleData(self.latDest!,lngDest: self.lngDest!,latStart: self.latStart!,lngStart: self.lngStart!)
            self.googleCalled = true
            
        } else {   self.notificationCenter.addObserverForName("LocationDidUpdate", object: nil, queue: self.mainQueue) { _ in
            
            if let loc2d: CLLocationCoordinate2D =  self.locationManager.currentLocation2d {
                
                self.latStart = Float(loc2d.latitude)
                self.lngStart = Float(loc2d.longitude)
                
                if self.googleCalled == false {
                    self.gApi.fetchGoogleData(self.latDest!,lngDest: self.lngDest!,latStart: self.latStart!,lngStart: self.lngStart!)
                    self.googleCalled = true
                }
            }
        }
        }
        

    }
    
    func didReceiveGoogleResults(results: Array<String>) {

        self.distanceToStart = results[0].toInt()!

        self.departureStationName = results[1]
       
        self.bartApiController.searchBartFor(self.departureStationName)
        

        
    }
    
    // Conform to BartApiControllerProtocol by implementing this method
    func didReceiveBartResults(results: [(String, Int)]) {
        println("Gotback from bart")
        println("Bart Results are \(results)")
        self.bartResults = results
        self.performSegueWithIdentifier("ResultsSegue", sender: self)
        
        
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!)  {
        
        println("preparing to segue")

        var destinationController = segue.destinationViewController as ResultViewController
        destinationController.distance = self.distanceToStart
        destinationController.departureStationName = self.departureStationName
        destinationController.departures = self.bartResults!
    }

    

    
    
}
