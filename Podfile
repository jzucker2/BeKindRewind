source 'https://github.com/CocoaPods/Specs.git'
workspace 'BeKindRewind.xcworkspace'
xcodeproj 'Example/BeKindRewind.xcodeproj'
use_frameworks!


target 'BKR-Tests-iOS-ObjC', :exclusive => true do
  platform :ios, '8.0'
  pod "OHHTTPStubs", :git => 'https://github.com/jzucker2/OHHTTPStubs.git', :branch => 'on-stub-end-one-place'
  pod "BeKindRewind", :path => "."
end

#target 'BKR-Tests-OSX-ObjC', :exclusive => true do
#    platform :osx, '10.9'
#    pod "BeKindRewind/Core", :path => "."
#end
