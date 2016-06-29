#
# Be sure to run `pod lib lint BeKindRewind.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "BeKindRewind"
  s.version          = "3.0.0"
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

  # The Core subspec, containing the library core needed in all cases
  s.subspec 'Misc' do |misc|
    misc.source_files = "BeKindRewind/Misc/*.{h,m}"
    misc.public_header_files = "BeKindRewind/Misc/*.h"
  end

  # The Core subspec, containing the library core needed in all cases
  s.subspec 'Core' do |core|
    core.dependency 'BeKindRewind/Misc'
    core.source_files = "BeKindRewind/Core/**/*.{h,m}"
    core.public_header_files = "BeKindRewind/Core/**/*.h"
  end

  # Optional subspecs
  s.subspec 'Recorder' do |recorder|
    # recorder.dependency 'BeKindRewind/Misc'
    recorder.dependency 'BeKindRewind/Core'
    recorder.source_files = "BeKindRewind/Recorder/**/*.{h,m}"
    recorder.public_header_files = "BeKindRewind/Recorder/**/*.h"
  end

  s.subspec 'Player' do |player|
    # player.dependency 'BeKindRewind/Misc'
    player.dependency 'OHHTTPStubs', '~> 5.0.0'
    player.dependency 'BeKindRewind/Core'
    player.source_files = "BeKindRewind/Player/**/*.{h,m}"
    player.public_header_files = "BeKindRewind/Player/**/*.h"
  end

  s.subspec 'VCR' do |vcr|
    vcr.dependency 'BeKindRewind/Recorder'
    vcr.dependency 'BeKindRewind/Player'
    vcr.source_files = "BeKindRewind/VCR/**/*.{h,m}"
    vcr.public_header_files = "BeKindRewind/VCR/**/*.h"
  end

  s.subspec 'FilePathHelper' do |file_path_helper|
    file_path_helper.dependency 'BeKindRewind/Misc'
    file_path_helper.source_files = "BeKindRewind/FilePathHelper/*.{h,m}"
    file_path_helper.public_header_files = "BeKindRewind/FilePathHelper/*.h"
  end

  s.subspec 'TestCaseFilePathHelper' do |test_case_file_path_helper|
    # test_case_file_path_helper.dependency 'BeKindRewind/Misc'
    test_case_file_path_helper.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '$(PLATFORM_DIR)/Developer/Library/Frameworks' }
    test_case_file_path_helper.framework = 'XCTest'
    test_case_file_path_helper.dependency 'BeKindRewind/FilePathHelper'
    test_case_file_path_helper.source_files = "BeKindRewind/TestCaseFilePathHelper/*.{h,m}"
    test_case_file_path_helper.public_header_files = "BeKindRewind/TestCaseFilePathHelper/*.h"
  end

  s.subspec 'TestCaseVCR' do |test_case_vcr|
    # test_case_vcr.dependency 'BeKindRewind/Misc'
    # test_case_vcr.dependency 'BeKindRewind/Core'
    # test_case_vcr.dependency 'BeKindRewind/Recorder'
    # test_case_vcr.framework = 'XCTest'
    test_case_vcr.dependency 'BeKindRewind/VCR'
    test_case_vcr.dependency 'BeKindRewind/TestCaseFilePathHelper'
    test_case_vcr.source_files = "TestCaseVCR/*.{h,m}"
    test_case_vcr.public_header_files = "TestCaseVCR/*.h"
  end

  # Default subspec that includes the most commonly-used components
  s.subspec 'Default' do |default|
    # default.dependency 'BeKindRewind/Misc'
    # default.dependency 'BeKindRewind/Core'
    # default.dependency 'BeKindRewind/Recorder'
    # default.dependency 'BeKindRewind/Player'
    # default.dependency 'BeKindRewind/VCR'
    # default.dependency 'BeKindRewind/FilePathHelper'
    # default.dependency 'BeKindRewind/TestCaseFilePathHelper'
    default.dependency 'BeKindRewind/TestCaseVCR'
    default.source_files = [
      "BeKindRewind/BeKindRewind.h"
    ]
    default.public_header_files = [
      "BeKindRewind/BeKindRewind.h",
    ]
    default.private_header_files = [
      'BeKindRewind/Player/OHHTTPStubs/BKRResponseStub+Private.h'
    ]

  end

  # s.source_files = [
  #   'BeKindRewind/BeKindRewind.h',
  #   'BeKindRewind/**/*.h'
  #   ]
  # s.public_header_files = [
  #   'BeKindRewind/BeKindRewind.h',
  #   'BeKindRewind/**/*.h'
  #   ]
  # s.dependency 'OHHTTPStubs', '~> 5.0.0'
  # s.framework = 'XCTest'
  # s.source_files = 'BeKindRewind/Core/**/*'
  # s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '$(PLATFORM_DIR)/Developer/Library/Frameworks' }
  # s.private_header_files = [
  #   'BeKindRewind/Core/OHHTTPStubs/BKRResponseStub+Private.h'
  #   ]
  s.default_subspec = 'Default'

end
