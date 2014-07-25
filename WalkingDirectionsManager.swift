//
//  WalkingDirectionsManager.swift
//  Should I Run
//
//  Created by Roger on 7/24/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import MapKit

let SharedWalkingDirectionsManager = WalkingDirectionsManager()

class WalkingDirectionsManager: NSObject {
    

    class var manager: WalkingDirectionsManager {
    return SharedWalkingDirectionsManager
    }
    
    init () {
        

    }
    
    func getWalkingDirectionsDistanceBetween(startLatLon:(lat:String, lon:String), endLatLon:(lat:String, lon:String)) {
        var walkingRouteRequest = MKDirectionsRequest()
        walkingRouteRequest.transportType = MKDirectionsTransportType.Walking
        

        let sourceMapItem = stringCorrdToMapItem(startLatLon.lat, lon: startLatLon.lon)
        let endMapItem = stringCorrdToMapItem(endLatLon.lat, lon: endLatLon.lon)
        
        walkingRouteRequest.setSource(sourceMapItem)
        walkingRouteRequest.setDestination(endMapItem)

        
    }
    
    func stringCorrdToMapItem(lat:String, lon:String) -> MKMapItem {
        
        var latDouble = (lat as NSString).doubleValue
        var lonDouble = (lon as NSString).doubleValue
        
        var coord2d = CLLocationCoordinate2DMake(CLLocationDegrees(latDouble), CLLocationDegrees(lonDouble))
        
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coord2d, addressDictionary: nil))
        
        return mapItem

        
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