# BeKindRewind

[![Build Status](https://travis-ci.org/jzucker2/BeKindRewind.svg?branch=master)](https://travis-ci.org/jzucker2/BeKindRewind)
[![Version](https://img.shields.io/cocoapods/v/BeKindRewind.svg?style=flat)](http://cocoapods.org/pods/BeKindRewind)
[![License](https://img.shields.io/cocoapods/l/BeKindRewind.svg?style=flat)](http://cocoapods.org/pods/BeKindRewind)
[![Platform](https://img.shields.io/cocoapods/p/BeKindRewind.svg?style=flat)](http://cocoapods.org/pods/BeKindRewind)

Easy XCTestCase subclass for recording and replaying network events for integration testing

## Features

* Easy recording and replaying of network events
* Provides full functionality in a simple XCTestCase subclass
* Can create custom matchers for building network stubs

## Description
This is an easy testing framework for recording and replaying network events for automated integration testing. In order to reduce tedium around creating network stubs, it records live network requests and responses and then replays them in subsequent runs (thanks to the fabulous [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs)) so that your software can in continunous integration without flakiness.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

BeKindRewind is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "BeKindRewind"
```

## Example

```objective-c
#import <BeKindRewind/BeKindRewind.h>

@interface BeKindRewindExampleTestCase : BKRTestCase
@end

@implementation BeKindRewindExampleTestCase

- (BOOL)isRecording {
    return YES;
}

- (void)testSimpleNetworkCall {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://httpbin.org/get?test=test"]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    
    // don't forget to create a test expectation
    XCTestExpectation *networkExpectation = [self expectationWithDescription:@"network"];
    NSURLSessionDataTask *basicGetTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        XCTAssertNotNil(data);
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        XCTAssertNil(error);
        XCTAssertEqualObjects(dataDict[@"args"], @{@"test" : @"test"});
        // fulfill the expectation
        [networkExpectation fulfill];
    }];
    [basicGetTask resume];
    // explicitly wait for the expectation
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
        	 // Assert fail if timeout encounters an error
        	 XCTAssertNil(error);
        }
    }];
}

```

After running this test, files will be outputted to the console with a log similar to this:

```bash
2016-02-28 17:12:25.175 xctest[44265:13063191] <BKRRecordableVCR: 0x7f88487052f0>: trying to write cassette to: /Users/jordanz/Library/Developer/CoreSimulator/Devices/6C6825EE-3B1E-48A9-98B7-AEE9FAE2CFC2/data/Documents/BeKindRewindExampleTestCase.bundle/testSimpleNetworkCall.plist
```

Drag this into your project as a bundle named after your test case (it is named automatically).

Then flip the `isRecording` value to NO:

```objective-c
- (BOOL)isRecording {
	return NO;
}
```

Then on subsequent runs, the tests will use the recorded files to respond to matched network requests.

## BKRTestCase Defaults

These are set automatically. Feel free to override with appropriate values but it is not necessary if these will suffice. It is possible these defaults will change until version 1.0 lands. A note about recording and playback, they are only valid after `[super setUp]` and before `[super tearDown]`

```objective-c
- (BOOL)isRecording {
    return YES;
}

- (NSString *)baseFixturesDirectoryFilePath {
    return [BKRTestCaseFilePathHelper documentsDirectory];
}

- (BKRTestConfiguration *)testConfiguration {
    return [BKRTestConfiguration defaultConfigurationWithTestCase:self];
}

- (id<BKRTestVCRActions>)testVCRWithConfiguration:(BKRTestConfiguration *)configuration {
    return [BKRTestVCR vcrWithTestConfiguration:configuration];
}

- (NSString *)recordingCassetteFilePathWithBaseDirectoryFilePath:(NSString *)baseDirectoryFilePath {
    NSParameterAssert(baseDirectoryFilePath);
    return [BKRTestCaseFilePathHelper writingFinalPathForTestCase:self inTestSuiteBundleInDirectory:baseDirectoryFilePath];
}

- (BKRCassette *)playingCassette {
    NSDictionary *cassetteDictionary = [BKRTestCaseFilePathHelper dictionaryForTestCase:self];
    XCTAssertNotNil(cassetteDictionary);
    return [BKRCassette cassetteFromDictionary:cassetteDictionary];
}

- (BKRCassette *)recordingCassette {
    return [BKRCassette cassette];
}

```

## Basic Testing Strategy

Try to avoid writing a test that is dependent upon state. Instead, ensure that when `isRecording == YES` that the test can be fully recorded for playback, including setUp and tearDown. This eases development and ensures that the test isn't written on a condition that wouldn't be recreated when another developer tries to update your test with a new recording.

## Support for iOS 7

Use version 0.6.x or lower of [JSZVCR](https://github.com/jzucker2/JSZVCR.git) if you want to test against iOS 7 or lower.

## Author

Jordan Zucker, jordan.zucker@gmail.com

## License

BeKindRewind is available under the MIT license. See the LICENSE file for more info.

## Release criteria
* proper support for redirects
* handle multi-part data
* tests for matcher classes
* tests for OSX, tvOS

## Future features
* swift tests (at least basic)/Swift Package Manager
* Code example for playing back in the README (not just recording)
* explain fixture write directory hack for easy recording
* Separate into subspecs
* add code coverage
* test different types of errors (timeout, invalid url) for playing/recording
* Tests for different types of NSURLSession (shared, ephemeral, standard, background, etc). Make different test case classes for each type of session
* afnetworking tests
* test for other types of network requests (streaming)
* timing taken into consideration
* blog post
* JSON serializing in addition to plist serializing
