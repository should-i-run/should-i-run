'use strict';

export function getClosestEntrance(station, start) {
  const getDistance = function(entrance) {
    const latDistance = Math.pow((start.lat - entrance.lat), 2);
    const lngDistance = Math.pow((start.lng - entrance.lng), 2);
    return Math.sqrt(lngDistance + latDistance);
  };
  if (station.entrances.length) {
    const sortedEntrances = station.entrances.sort((a, b) => getDistance(a) >= getDistance(b));
    return sortedEntrances[0];
  }
  return {lat: station.gtfs_latitude, lng: station.gtfs_longitude};
};
    // figure out the closest of the 'entrances' and use it.
      // func getDistance(e: AnyObject) -> Double{
      //     let lngDistance: Double = pow((startCoord.latitude - (e["lat"] as! Double)), 2)
      //     let     latDistance: Double = pow((startCoord.longitude - (e["lng"] as! Double)), 2)
      //     return sqrt(lngDistance + latDistance)
      // }
      // let sortedEntrances = entrances.sorted {
      //     return getDistance(e: $0 as AnyObject) <= getDistance(e: $1 as AnyObject)
      // }
      // let winner = sortedEntrances[0]
    //
    //   Linking.openURL(`http://maps.apple.com/?daddr=${lat},${lng}&dirflg=w&t=r`);
    // };
