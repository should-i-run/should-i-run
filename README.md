# Should I Run?

> We help you catch the first possible BART train using real-time transit data.

## Features
* Add destinations you want to get to using BART.
* Run or walk recommendation depending on the next incoming train.
* Time in miutues of when the next makable train will arrive.
* Time and distance estimation based on your current location.
* Set an alarm to notify you when to leave to catch your train.

## Development

1. Xcode etc
2. Product > Scheme > Edit Scheme, change to Debug from Release
3. start the react-native dev server: `(JS_DIR=`pwd`/Should_I_Run/ReactComponents; cd node_modules/react-native; npm run start -- --root $JS_DIR)`

### Build for phone
1. Product > Scheme > Edit Scheme, change to Release from Debug


### Updating
`npm install --save react-native@[current version]`
`pod update`
you may have to specify the new version in the Podfile and run `pod install`
