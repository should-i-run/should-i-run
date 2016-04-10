'use strict';

import React, {
  Text,
  View
} from 'react-native';

const text = {
  color: '#DDD'
};

var styles = React.StyleSheet.create({
  station: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'flex-start',
    padding: 10,
  },
  stationInfo: {
    flexDirection: 'row',
    justifyContent: 'flex-start',
  },
  line: {
    flexDirection: 'row',
    justifyContent: 'flex-start',
    alignItems: 'center',
  },
  departure: {
    marginLeft: 5,
  },
  stationName: {
    ...text,
    fontSize: 24,
    fontWeight: '400',
  },
  genericText: {
    ...text,
    fontSize: 18,
    fontWeight: '400',
  },
  timeLabel: {
    ...text,
    fontSize: 18,
    fontWeight: '400',
    marginLeft: 15,
  },
  departureTime: {
    ...text,
    fontSize: 18,
    fontWeight: '800',
    marginLeft: 15,
  },
  missed: {
    color: '#AAA',
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
        <Text style={styles.genericText}>{eolStationName} </Text>
        {currentDepartures.map(this.renderDeparture.bind(this))}
      </View>
    );
  }

  render() {
    const s = this.props.station;
    return (
      <View style={styles.station}>
        <Text style={styles.stationName}>{s.stationName}</Text>
        <View style={styles.stationInfo}>
          <Text style={styles.genericText}>
            {s.distanceToStation} m
          </Text>

          <Text style={styles.timeLabel}>
            {s.runningTime} running
          </Text>
          <Text style={styles.timeLabel}>
            {s.walkingTime} walking
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
