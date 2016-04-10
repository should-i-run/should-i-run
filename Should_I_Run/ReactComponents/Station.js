'use strict';

import React, {
  Text,
  View
} from 'react-native';

var styles = React.StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'red'
  }
});

export default class Station extends React.Component {
  static propTypes = {
    station: React.PropTypes.object,
  }

  render() {
    return (
      <Text>{this.props.station.stationName}</Text>
    );
  }
}
