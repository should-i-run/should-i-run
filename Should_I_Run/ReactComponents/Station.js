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
    const {departureTime, shouldRun} = departure;
    let labelStyle = styles.walk;
    if (shouldRun) {
      labelStyle = departureTime >= this.props.station.runningTime ?
        styles.run : styles.missed;
    }
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
    const {eolStationName, departures} = line;
    const currentDepartures = departures.filter(d => d.departureTime >= 0);
    return (
      <View key={i} style={styles.line}>
        <Text
          numberOfLines={2}
          style={styles.lineName}>
          {eolStationName}
        </Text>
        <View style={styles.depTimeContainer}>
          {currentDepartures.map(this.renderDeparture.bind(this))}
        </View>
      </View>
    );
  }

  render() {
    const s = this.props.station;
    return (
      <View style={styles.station}>
        <Text style={styles.stationName}>{s.stationName}</Text>
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
        {s.lines.map(this.renderLine.bind(this))}
      </View>
    );
  }
}

// "distanceToStation": self.distanceToStation!,
// "stationName": self.stationName,
// "agency": self.agency,
// "stationTime": self.stationTime,
// "walkingTime": self.walkingTime ?? "",
// "runningTime": self.runningTime ?? "",
// "lines": self.lines.map({$0.toDictionary()})
