Pod::Spec.new do |s|
  s.name             = 'VMSDK_Legacy'
s.version='v2.2.0-beta.3'
  s.summary          = 'Aegir Maps SDK for iOS'
  s.description      = 'The Aegir SDK is a set of libraries for JavaScript, iOS, and Android that allows development of applications that interact with Venue Maps from the Aegir platform, sometimes called VMDs. The SDK is a proprietary product of Lokion, LLC, and is not open source.'
  s.homepage         = 'https://www.aegirmaps.com'

  s.license          = {
    :type => 'custom',
    :file => 'LICENSE.txt'
  }
  s.author = 'dsmith@lokion.com'
  s.source            = { :http => "https://vmsdk-releases.s3.us-east-2.amazonaws.com/EVAL/iOS/#{s.version}/pods/#{s.name}.zip" }

  s.platforms = {
    :ios => '13.0'
  }

  s.ios.deployment_target = '13.0'

  s.frameworks = 'CoreData', 'CoreGraphics', 'CoreLocation', 'CoreTelephony', 'QuartzCore', 'SystemConfiguration', 'UIKit'
  s.vendored_frameworks = "#{s.name}.xcframework"
 
end
