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
    location: React.PropTypes.object,
  }

  render() {
    const {location, walkingData, data} = this.props;
    return (
      <ScrollView style={styles.container}>
        {data && data.map((s, i) =>
          <Station key={i} station={s} walking={walkingData[s.abbr]} location={location}/>)}
      </ScrollView>
    )
  }
}

export default App;
