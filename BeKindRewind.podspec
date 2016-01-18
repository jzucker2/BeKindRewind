#
# Be sure to run `pod lib lint BeKindRewind.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "BeKindRewind"
  s.version          = "0.1.0"
  s.summary          = "A simple way to record and replay network requests for testing."
  s.description      = <<-DESC
                        Provides an XCTestCase subclass for easily
                        recording and then replaying network requests
                        and responses during testing and testing development
                       DESC

  s.homepage         = "https://github.com/jzucker2/BeKindRewind"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Jordan Zucker" => "jordan.zucker@gmail.com" }
  s.source           = { :git => "https://github.com/jzucker2/BeKindRewind.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/jzucker'

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.osx.deployment_target = '10.9'
  s.requires_arc = true
  s.dependency 'OHHTTPStubs', '~> 4.7.0'

#s.source_files = 'Pod/Classes/**/*'
#  s.resource_bundles = {
#    'BeKindRewind' => ['Pod/Assets/*.png']
#  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

  s.subspec 'Core' do |core|
    core.ios.deployment_target = '8.0'
    core.tvos.deployment_target = '9.0'
    core.osx.deployment_target = '10.9'
    core.watchos.deployment_target = '2.0'
    core.source_files = 'BeKindRewind/Core/**/*'
    core.exclude_files = "BeKindRewind/Classes/XCTest/*"
  end

  s.subspec 'Testing' do |testing|
    testing.framework = 'XCTest'
    testing.dependency 'BeKindRewind/Core'
    testing.source_files = "BeKindRewind/Classes/XCTest/*"
    testing.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'BKRTESTING=1'  }
    testing.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'BKRTESTING=1'  }
  end

  s.default_subspec = 'Testing'
end
