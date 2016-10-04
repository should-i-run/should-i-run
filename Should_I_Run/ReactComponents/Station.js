'use strict';

import React from 'react';
import {
  Text,
  View,
  StyleSheet,
  Linking,
} from 'react-native';

import {getClosestEntrance} from './utils/distance.js';

// let walkingSpeed = 80 //meters per minute
const runningSpeed = 200 //meters per minute

const genericText = {
  color: '#E6E6E6',
  fontSize: 18,
  fontWeight: '200',
};

var styles = StyleSheet.create({
  genericText: {
    ...genericText,
  },
  stationName: {
    ...genericText,
    fontSize: 26,
    flex: 5,
  },
  stationMetadata: {
    ...genericText,
    fontSize: 14,
    marginRight: 15,
    color: '#AAA',
  },
  departureTime: {
    ...genericText,
    width: 35,
    textAlign: 'right',
    fontSize: 26,
  },
  lineName: {
    ...genericText,
    width: 120,
  },
  direction: {
    backgroundColor: '#344453',
    padding: 5,
    marginTop: 10,
    borderRadius: 2,
    paddingLeft: 10,
  },
  directionText: {
    ...genericText,
    fontSize: 14,
    color: '#AAA',
    marginBottom: -5,
  },
  stationDistance: {
    ...genericText,
    color: '#AAA',
    fontSize: 26,
    flex: 4,
    marginRight: 10,
    textAlign: 'right',
  },
  stationNameContainer: {
    flexDirection: 'row',
    justifyContent: 'flex-start',
    alignItems: 'center',
  },
  station: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'flex-start',
    padding: 10,
    paddingTop: 30,
    marginBottom: 20,
  },
  stationNameContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  stationMetadataContainer: {
    flexDirection: 'row',
    justifyContent: 'flex-start',
    paddingLeft: 10,
    marginTop: 10,
  },
  departure: {
    marginLeft: 5,
  },
  line: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 10,
  },
  depTimeContainer: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  missed: {
    color: '#999',
  },
  run: {
    color: '#FC5B3F',
    // fontWeight: '400',
  },
  walk: {
    color: '#6FD57F',
    // fontWeight: '400',
  },
});

const getRunningTime = (distance) => {
  return Math.ceil(distance / runningSpeed);
}

export default class Station extends React.Component {
  static propTypes = {
    station: React.PropTypes.object.isRequired,
    walking: React.PropTypes.object,
  }

  renderDeparture = (departure, i) => {
    if (departure === 'blank') {
      return (
        <View key={i} style={styles.departure}>
          <Text style={[styles.departureTime, labelStyle]}>
            {' '}
          </Text>
        </View>
      );
    }
    const {distance, time} = this.props.walking || {};
    const departureTime = departure === 'Leaving' ? 0 : departure;
    let labelStyle = styles.missed;
    if (departureTime >= time) {
      labelStyle = styles.walk;
    } else if (departureTime >= getRunningTime(distance)) {
      labelStyle = styles.run;
    }
    return (
      <View key={i} style={styles.departure}>
        <Text style={[styles.departureTime, labelStyle]}>
          {departureTime}
        </Text>
      </View>
    );
  }

  renderLine = (line, i) => {
    const {destination, estimates} = line;
    const times = estimates.map(e => e.minutes);
    while (times.length < 3) {
      times.push('blank');
    }
    return (
      <View key={i} style={styles.line}>
        <Text
          numberOfLines={2}
          style={styles.lineName}>
          {destination}
        </Text>
        <View style={styles.depTimeContainer}>
          {times.map(this.renderDeparture)}
        </View>
      </View>
    );
  }

  renderStationName = (s, distance) => {
    const goToDirections = () => {
      const {lat, lng} = getClosestEntrance(s, this.props.location);
      Linking.openURL(`http://maps.apple.com/?daddr=${lat},${lng}&dirflg=w&t=r`);
    };
    return (
      <View style={styles.stationNameContainer}>
        <Text style={styles.stationName} numberOfLines={1}>{s.name}</Text>
        <Text style={[styles.stationDistance]} onPress={goToDirections}>
          {typeof distance === 'number' ? distance.toLocaleString() : '...'} meters
        </Text>
      </View>
    );
  }

  render() {
    const s = this.props.station;
    const {distance, time} = this.props.walking || {};
    const isMakable = (estimate) => estimate.minutes >= time;
    const makableDepartureTime = (a, b) => {
      const aBest = a.estimates.filter(isMakable)[0];
      const aMinutes =  aBest ? aBest.minutes : 999;
      const bBest = b.estimates.filter(isMakable)[0];
      const bMinutes =  bBest ? bBest.minutes : 999;
      return parseInt(aMinutes, 10) - parseInt(bMinutes, 10);
    }

    const north = s.departures
      .filter(d => d.estimates[0].direction === 'North')
      .sort(makableDepartureTime);
    const south = s.departures
      .filter(d => d.estimates[0].direction === 'South')
      .sort(makableDepartureTime);
    return (
      <View style={styles.station}>
        {this.renderStationName(s, distance)}
        <View style={styles.stationMetadataContainer}>
          <Text style={styles.stationMetadata}>
            Running:
            <Text style={styles.run}> {typeof distance === 'number' ? getRunningTime(distance) : '...'} min</Text>
          </Text>
          <Text style={styles.stationMetadata}>
            Walking:
            <Text style={styles.walk}> {typeof time === 'number' ? (time || 1) : '...'} min</Text>
          </Text>
        </View>

        {!!north.length &&
          <View style={styles.direction}>
            <Text style={styles.directionText}>Northbound departuers</Text>
            {north.map(this.renderLine)}
          </View>}
        {!!south.length &&
          <View style={styles.direction}>
            <Text style={styles.directionText}>Southbound departures</Text>
            {south.map(this.renderLine)}
          </View>}
      </View>
    );
  }
}


// "address": "899 Market Street",
// "departures": [
//   {
//     "code": "DALY",
//     "departures": [
//       "8",
//       "27",
//       "47"
//     ]
//   },
// "gtfs_longitude": "-122.406857",
// "name": "Powell St.",
// "city": "San Francisco",
// "county": "sanfrancisco",
// "abbr": "POWL",
// "state": "CA",
// "zipcode": "94102",
// "distance": 0.0027096245127228285,
// "gtfs_latitude": "37.784991"
