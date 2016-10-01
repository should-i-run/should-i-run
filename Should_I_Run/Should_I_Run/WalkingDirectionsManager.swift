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
    func handleWalkingDistance(_ stationCode:String, distance:Int, time:Int)
}

class WalkingDirectionsManager: NSObject {
    
    var delegate : WalkingDirectionsDelegate?
    
    class var manager: WalkingDirectionsManager {
        return SharedWalkingDirectionsManager
    }
    
    func loc2dToMapItem(_ loc:CLLocationCoordinate2D) -> MKMapItem {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: loc, addressDictionary: nil))
        return mapItem
    }
    
    func getWalkingDirectionsBetween(_ startLatLon:CLLocationCoordinate2D, endLatLon:CLLocationCoordinate2D, stationCode: String) {
        let walkingRouteRequest = MKDirectionsRequest()
        walkingRouteRequest.transportType = MKDirectionsTransportType.walking
        
        let sourceMapItem = loc2dToMapItem(startLatLon)
        let endMapItem = loc2dToMapItem(endLatLon)
        walkingRouteRequest.source = sourceMapItem
        walkingRouteRequest.destination = endMapItem
        
        let walkingRouteDirections = MKDirections(request: walkingRouteRequest)
        walkingRouteDirections.calculate { (response: MKDirectionsResponse?, error: Error?) in
            if let distance = response?.routes[0].distance, let time = response?.routes[0].expectedTravelTime {
                self.delegate?.handleWalkingDistance(stationCode, distance: Int(distance), time: Int(time / 60))
            }
        }
    }
}
