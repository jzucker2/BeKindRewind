#
# Be sure to run `pod lib lint BeKindRewind.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "BeKindRewind"
  s.version          = "1.0.0"
  s.summary          = "A simple way to record and replay network requests for testing and debugging."
  s.description      = <<-DESC
                        Provides an XCTestCase subclass for easily
                        recording and then replaying network events
                        during testing and development.
                       DESC

  s.homepage         = "https://github.com/jzucker2/BeKindRewind"
  s.license          = 'MIT'
  s.author           = { "Jordan Zucker" => "jordan.zucker@gmail.com" }
  s.source           = { :git => "https://github.com/jzucker2/BeKindRewind.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/jzucker'

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.osx.deployment_target = '10.9'
  s.requires_arc = true
  s.dependency 'OHHTTPStubs', '~> 5.0.0'
  s.framework = 'XCTest'
  s.source_files = 'BeKindRewind/Core/**/*'
  s.prepare_command = 'ruby plist_resource_creator.rb'

  s.ios.resource_bundles = {
    'BeKindRewind-iOS' => ['BeKindRewind/Assets/*.plist']
  }

  s.tvos.resource_bundles = {
    'BeKindRewind-tvOS' => ['BeKindRewind/Assets/*.plist']
  }

  s.osx.resource_bundles = {
    'BeKindRewind-OSX' => ['BeKindRewind/Assets/*.plist']
  }

end
