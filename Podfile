platform :ios, '10.0'
use_frameworks!

workspace 'Should_I_Run'
project 'Should_I_Run/Should_I_Run.xcodeproj'

target 'Should_I_Run' do
  pod 'Alamofire', '~> 4.0'
  pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'

  pod 'React', :path => './node_modules/react-native', :subspecs => [
    'Core',
    'RCTImage',
    'RCTNetwork',
    'RCTText',
    'RCTWebSocket',
    # 'RCTLinking',
    # Add any other subspecs you want to use in your project
  ]
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
