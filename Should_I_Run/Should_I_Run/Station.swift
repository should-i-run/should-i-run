//
//  Station.swift
//  Should_I_Run
//
//  Created by Roger Goldfinger on 4/3/16.
//  Copyright © 2016 Should_I_Run. All rights reserved.
//

class Station {
    var distanceToStation: Int?
    var stationName: String
    var agency: String
    var stationTime = 2
    var walkingTime: Int?
    var runningTime: Int?
    var lines: [Line]
    
    init (departures: [Route], lines: [Line]) {
        let first = departures.first!
        self.lines = lines
        self.distanceToStation = first.distanceToStation
        self.stationName = first.originStationName
        self.agency = first.agency
        self.stationTime = first.stationTime
        self.walkingTime = first.walkingTime
        self.runningTime = first.runningTime
    }
}

class Line {
    var lineName: String
    var lineCode: String?
    var eolStationName: String
    var departures: [Route]
    
    init (departures: [Route]) {
        let first = departures.first!
        self.lineName = first.lineName
        self.lineCode = first.lineCode
        self.eolStationName = first.eolStationName
        self.departures = departures
    }
}
