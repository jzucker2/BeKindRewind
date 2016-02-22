#
# Be sure to run `pod lib lint BeKindRewind.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "BeKindRewind"
  s.version          = "0.9.0"
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
  s.dependency 'OHHTTPStubs', '~> 4.7.1'
  s.framework = 'XCTest'
  s.source_files = 'BeKindRewind/Core/**/*'
#  s.prefix_header_contents = '#import "BKRConstants.h"'
  s.prepare_command = 'ruby plist_resource_creator.rb'

#s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'BeKindRewind' => ['BeKindRewind/Assets/*.plist']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

#  s.subspec 'Recorder' do |recorder|
#    recorder.ios.deployment_target = '8.0'
#    recorder.tvos.deployment_target = '9.0'
#    recorder.osx.deployment_target = '10.9'
#    recorder.watchos.deployment_target = '2.0'
#    recorder.source_files = 'BeKindRewind/Core/**/*'
#    recorder.exclude_files = "BeKindRewind/Classes/XCTest/*"
#  end

#  s.subspec 'Testing' do |testing|
#    testing.framework = 'XCTest'
#    testing.dependency 'BeKindRewind/Recorder'
#    testing.source_files = "BeKindRewind/Classes/XCTest/*"
#    testing.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'BKRTESTING=1'  }
#    testing.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'BKRTESTING=1'  }
#  end

#  s.default_subspec = 'Recorder'
end
