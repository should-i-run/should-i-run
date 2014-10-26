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
    
    override init () {
        
        
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
        println("get dist from dir")

        response.routes[0].distance.hashValue
        var temp = Int(response.routes[0].distance)
        println(temp);
        self.delegate?.handleWalkingDistance(temp)

    }
}


/*
MKDirectionsRequest *walkingRouteRequest = [[MKDirectionsRequest alloc] init];
walkingRouteRequest.transportType = MKDirectionsTransportTypeWalking;
[walkingRouteRequest setSource:[startPoint mapItem]];
[walkingRouteRequest setDestination :[endPoint mapItem]];

MKDirections *walkingRouteDirections = [[MKDirections alloc] initWithRequest:walkingRouteRequest];
[walkingRouteDirections calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * walkingRouteResponse, NSError *walkingRouteError) {
if (walkingRouteError) {
[self handleDirectionsError:walkingRouteError];
} else {
// The code doesn't request alternate routes, so add the single calculated route to
// a previously declared MKRoute property called walkingRoute.
self.walkingRoute = walkingRouteResponse.routes[0];
}
}];

*/