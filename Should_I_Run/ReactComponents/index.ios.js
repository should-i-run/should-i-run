'use strict';

import React, {
  Text,
  View
} from 'react-native';

import Station from './Station.js';

var styles = React.StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'red'
  }
});

class SimpleApp extends React.Component {
  static propTypes = {
    stations: React.PropTypes.array,
    routes: React.PropTypes.array,
  }


  render() {
    return (
      <View style={styles.container}>
        {this.props.stations && this.props.stations.map((s, i) => <Station key={i} station={s} />)}
      </View>
    )
  }
}

React.AppRegistry.registerComponent('SimpleApp', () => SimpleApp);
