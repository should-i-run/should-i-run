'use strict';

import React, {
  Text,
  View
} from 'react-native';

const genericText = {
  color: '#EEE',
  fontSize: 18,
  fontWeight: '400',
};

var styles = React.StyleSheet.create({
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
});

export default class Station extends React.Component {
  static propTypes = {
    station: React.PropTypes.object,
  }

  // "originStationName": self.originStationName,
  // "lineName": self.lineName,
  // "eolStationName": self.eolStationName,
  // "agency": self.agency,
  // "departureTime": self.departureTime ?? "",
  // "lineCode": self.lineCode ?? "",
  // "distanceToStation": self.distanceToStation ?? "",
  // "shouldRun": self.shouldRun,
  renderDeparture(departure, i) {
    // const {departureTime, shouldRun} = departure;
    let labelStyle = styles.walk;
    // if (shouldRun) {
    //   labelStyle = departureTime >= this.props.station.runningTime ?
    //     styles.run : styles.missed;
    // }
    const departureTime = departure === 'Leaving' ? 0 : departure;
    return (
      <View key={i} style={styles.departure}>
        <Text style={[styles.departureTime, labelStyle]}>
          {departureTime}
        </Text>
      </View>
    );
  }

  // self.lineName = first.lineName
  // self.lineCode = first.lineCode
  // self.eolStationName = first.eolStationName
  // self.departures = departures
  renderLine(line, i) {
    const {code, departures} = line;
    // const currentDepartures = departures.filter(d => d.departureTime >= 0);
    return (
      <View key={i} style={styles.line}>
        <Text
          numberOfLines={2}
          style={styles.lineName}>
          {code}
        </Text>
        <View style={styles.depTimeContainer}>
          {departures.map(this.renderDeparture.bind(this))}
        </View>
      </View>
    );
  }

  render() {
    const s = this.props.station;
    return (
      <View style={styles.station}>
        <Text style={styles.stationName}>{s.name}</Text>
        <View style={styles.stationMetadataContainer}>
          <Text style={styles.stationMetadata}>
            {s.distanceToStation} m
          </Text>
          <Text style={styles.stationMetadata}>
            <Text>{s.runningTime} </Text>
            running
          </Text>
          <Text style={styles.stationMetadata}>
            <Text>{s.walkingTime} </Text>
            walking
          </Text>
        </View>
        {s.departures.map(this.renderLine.bind(this))}
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
