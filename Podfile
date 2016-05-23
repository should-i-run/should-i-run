platform :ios, '9.0'
use_frameworks!

workspace 'Should_I_Run'
xcodeproj 'Should_I_Run/Should_I_Run.xcodeproj'

target 'Should_I_Run' do
  pod 'Alamofire', '~> 3.0'
  pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'

  pod 'React', :path => './node_modules/react-native', :subspecs => [
    'Core',
    'RCTImage',
    'RCTNetwork',
    'RCTText',
    'RCTWebSocket',
    # Add any other subspecs you want to use in your project
  ]
end
