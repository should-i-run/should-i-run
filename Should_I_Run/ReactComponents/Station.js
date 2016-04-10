'use strict';

import React, {
  Text,
  View
} from 'react-native';

var styles = React.StyleSheet.create({
  station: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'flex-start',
    backgroundColor: 'red'
  },
  stationInfo: {
    flexDirection: 'row',
    justifyContent: 'flex-start',
    alignItems: 'center',
  },
  line: {
    flexDirection: 'row',
    justifyContent: 'flex-start',
    alignItems: 'center',
  },
  departure: {
    marginLeft: 5,
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
    const {departureTime} = departure;
    return (
      <View key={i} style={styles.departure}>
        <Text>{departureTime}</Text>
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
        <Text>{eolStationName} </Text>
        {currentDepartures.map(this.renderDeparture)}
      </View>
    );
  }

  render() {
    const s = this.props.station;
    return (
      <View style={styles.station}>
        <Text>{this.props.station.stationName}</Text>
        <View style={styles.stationInfo}>
          <Text>{s.distanceToStation} meters</Text>
          <Text>Running time: {s.runningTime}</Text>
          <Text>Walking time: {s.walkingTime}</Text>
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
