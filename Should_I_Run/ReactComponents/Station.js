'use strict';

import React from 'react';
import {
  Text,
  View,
  StyleSheet,
} from 'react-native';

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
    // paddingLeft: 10,
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

  render() {
    const s = this.props.station;
    const {distance, time} = this.props.walking || {};
    const north = s.departures.filter(d => d.estimates[0].direction === 'North');
    const south = s.departures.filter(d => d.estimates[0].direction === 'South');
    return (
      <View style={styles.station}>
        <View style={styles.stationNameContainer}>
          <Text style={styles.stationName}>{s.name}</Text>
          <Text style={[styles.stationDistance]}>
            {distance ? distance.toLocaleString() : '...'} meters
          </Text>
        </View>

        <View style={styles.stationMetadataContainer}>
          <Text style={styles.stationMetadata}>
            Running:
            <Text style={styles.run}> {distance ? getRunningTime(distance) : '...'} min</Text>
          </Text>
          <Text style={styles.stationMetadata}>
            Walking:
            <Text style={styles.walk}> {time || '...'} min</Text>
          </Text>
        </View>

        {!!north.length &&
          <View style={styles.direction}>
            <Text style={styles.directionText}>North</Text>
            {north.map(this.renderLine)}
          </View>}
        {!!south.length &&
          <View style={styles.direction}>
            <Text style={styles.directionText}>South</Text>
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
