# Uncomment the next line to define a global platform for your project
 platform :ios, '9.0'

target 'Yaknak' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'FBSDKCoreKit'
  pod 'FBSDKLoginKit'
  pod 'FBSDKShareKit'
  pod 'Koloda', '~> 4.0'
  pod 'MBProgressHUD'
  pod 'HTHorizontalSelectionList'
  pod 'RSKPlaceholderTextView'
  pod 'NVActivityIndicatorView', '~> 3.6.1'
  pod 'GooglePlaces'
  pod 'GoogleMaps'
  pod 'GeoFire', :git => 'https://github.com/firebase/geofire-objc.git'
  pod 'Kingfisher'

end

post_install do |installer|
    `find Pods -regex 'Pods/pop.*\\.h' -print0 | xargs -0 sed -i '' 's/\\(<\\)pop\\/\\(.*\\)\\(>\\)/\\"\\2\\"/'`
end

