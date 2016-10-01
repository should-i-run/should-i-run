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
  color: '#EEE',
  fontSize: 18,
  fontWeight: '400',
};

var styles = StyleSheet.create({
  genericText: {
    ...genericText,
  },
  station: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'flex-start',
    padding: 10,
  },
  stationName: {
    ...genericText,
    fontSize: 24,
    fontWeight: '400',
  },
  stationMetadataContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 5,
  },
  stationMetadata: {
    ...genericText,
    fontSize: 18,
    fontWeight: '200',
    marginRight: 15,
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
  lineName: {
    ...genericText,
    width: 120,
    fontWeight: '200',
  },
  depTimeContainer: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'flex-start',
  },
  departureTime: {
    ...genericText,
    fontWeight: '800',
    marginLeft: 15,
    width: 25,
    textAlign: 'right',
  },
  missed: {
    color: '#999',
  },
  run: {
    color: '#FC5B3F',
  },
  walk: {
    color: '#6FD57F',
  },
  direction: {
    ...genericText,
    width: 500,
    fontWeight: '200',
    backgroundColor: '#555',
    padding: 5,
    marginTop: 10,
    borderRadius: 2,
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

  renderDeparture(departure, i) {
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

  renderLine(line, i) {
    const {destination, estimates} = line;
    const times = estimates.map(e => e.minutes);
    return (
      <View key={i} style={styles.line}>
        <Text
          numberOfLines={2}
          style={styles.lineName}>
          {destination}
        </Text>
        <View style={styles.depTimeContainer}>
          {times.map(this.renderDeparture.bind(this))}
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
        <Text style={styles.stationName}>{s.name}</Text>
        <View style={styles.stationMetadataContainer}>
          <Text style={styles.stationMetadata}>
            {distance} m
          </Text>
          <Text style={styles.stationMetadata}>
            <Text>{distance ? getRunningTime(distance) : ''} </Text>
            running
          </Text>
          <Text style={styles.stationMetadata}>
            <Text>{time} </Text>
            walking
          </Text>
        </View>
        <Text style={styles.direction}>North</Text>
        {north.map(this.renderLine.bind(this))}
        <Text style={styles.direction}>South</Text>
        {south.map(this.renderLine.bind(this))}
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
