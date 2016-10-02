'use strict';

import React from 'react';

import {
  Text,
  ScrollView,
  StyleSheet,
} from 'react-native';

import Station from './Station.js';

var styles = StyleSheet.create({
  container: {
    backgroundColor: '#252F39',
    paddingTop: 20,
  }
});

class App extends React.Component {
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

export default App;
