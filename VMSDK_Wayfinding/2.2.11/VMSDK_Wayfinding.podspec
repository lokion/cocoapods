Pod::Spec.new do |s|
  s.name             = 'VMSDK_Wayfinding'
  s.version          = '2.2.11'
  s.summary          = 'Aegir Maps SDK for iOS'
  s.description      = 'The Aegir SDK is a set of libraries for JavaScript, iOS, and Android that allows development of applications that interact with Venue Maps from the Aegir platform, sometimes called VMDs. The SDK is a proprietary product of Lokion, LLC, and is not open source.'
  s.homepage         = 'https://www.aegirmaps.com'

  s.license          = {
    :type => 'custom',
    :file => 'LICENSE.txt'
  }
  s.author = 'dsmith@lokion.com'
  s.source            = { :http => "https://github.com/lokion/cocoapods/releases/download/v2.2.11/VMSDK_Wayfinding.zip" }

  s.platforms = {
    :ios => '13.0'
  }

  s.ios.deployment_target = '13.0'

  s.frameworks = 'CoreData', 'CoreGraphics', 'CoreLocation', 'CoreTelephony', 'QuartzCore', 'SystemConfiguration', 'UIKit'
  s.vendored_frameworks = "VMSDK_Wayfinding.xcframework"

  s.dependency 'MapLibre', '5.12.0'
end
