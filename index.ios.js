'use strict';

import React from 'react';

import {
  Text,
  ScrollView,
  StyleSheet,
  AppRegistry,
} from 'react-native';

import Station from './Should_I_Run/ReactComponents/Station.js';

var styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'black',
  }
});

class SimpleApp extends React.Component {
  static propTypes = {
    data: React.PropTypes.array,
    walkingData: React.PropTypes.object,
  }

  render() {
    return (
      <ScrollView style={styles.container}>
        {this.props.data && this.props.data.map((s, i) =>
          <Station key={i} station={s} walking={this.props.walkingData[s.abbr]}/>)}
      </ScrollView>
    )
  }
}

AppRegistry.registerComponent('SimpleApp', () => SimpleApp);
