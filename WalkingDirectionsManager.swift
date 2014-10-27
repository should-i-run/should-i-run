//
//  WalkingDirectionsManager.swift
//  Should I Run
//
//  Created by Roger on 7/24/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import MapKit

let SharedWalkingDirectionsManager = WalkingDirectionsManager()

protocol WalkingDirectionsDelegate {
    func handleWalkingDistance(distance:Int)
    
}

class WalkingDirectionsManager: NSObject {
    
    var delegate : WalkingDirectionsDelegate?
    
    class var manager: WalkingDirectionsManager {
        return SharedWalkingDirectionsManager
    }
    
    func loc2dToMapItem(loc:CLLocationCoordinate2D) -> MKMapItem {
        
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: loc, addressDictionary: nil))
        return mapItem
        
    }
    
    func getWalkingDirectionsBetween(startLatLon:CLLocationCoordinate2D, endLatLon:CLLocationCoordinate2D) {
        
        var walkingRouteRequest = MKDirectionsRequest()
        walkingRouteRequest.transportType = MKDirectionsTransportType.Walking
        
        let sourceMapItem = loc2dToMapItem(startLatLon)
        let endMapItem = loc2dToMapItem(endLatLon)
        
        walkingRouteRequest.setSource(sourceMapItem)
        walkingRouteRequest.setDestination(endMapItem)
        
        var walkingRouteDirections = MKDirections(request: walkingRouteRequest)
        
        walkingRouteDirections.calculateDirectionsWithCompletionHandler(getDistanceFromDirections)
        
    }
    
    func getDistanceFromDirections(response:MKDirectionsResponse!, error: NSError?) -> Void {
        
        response.routes[0].distance.hashValue
        var temp = Int(response.routes[0].distance)
        self.delegate?.handleWalkingDistance(temp)
        
    }
}