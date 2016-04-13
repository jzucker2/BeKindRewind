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

    // don't forget to create a test expectation, this has the __block annotation because to avoid a retain cycle
    // XCTestExpectation is necessary for asynchronous network activity, BeKindRewind will take care of everything else
    __block XCTestExpectation *networkExpectation = [self expectationWithDescription:@"network"];
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
        // Assert fail if timeout encounters an error
        XCTAssertNil(error);
    }];
}

@end

```

After running this test, files will be outputted to the console with a log similar to this:

```bash
2016-03-02 10:09:27.630 xctest[92201:14865359] <BKRRecordableVCR: 0x7fb0a9714ce0>: trying to write cassette to: /Users/jordanz/Library/Developer/CoreSimulator/Devices/611CC72A-11D4-4DD2-8471-FF2F65413BC7/data/Documents/BeKindRewindExampleTestCase.bundle/testSimpleNetworkCall.plist
```

Drag this into your project as a bundle named after your test case (it is named automatically).

Then flip the `isRecording` value to NO:

```objective-c
- (BOOL)isRecording {
	return NO;
}
```

Then on subsequent runs, the tests will use the recorded files to respond to matched network requests. It helps to ensure recordings are being used by asserting on information that is specific to your recordings. An example is modifying the above test so that it asserts on the Date header in the NSHTTPURLResponse object returned during the test execution. Here's an example of how to update the test after creating a recording.

```objective-c
#import <BeKindRewind/BeKindRewind.h>

@interface BeKindRewindExampleTestCase : BKRTestCase
@end

@implementation BeKindRewindExampleTestCase

- (BOOL)isRecording {
    return NO;
}

- (void)testSimpleNetworkCall {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://httpbin.org/get?test=test"]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];

    // don't forget to create a test expectation, this has the __block annotation because to avoid a retain cycle
    // XCTestExpectation is necessary for asynchronous network activity, BeKindRewind will take care of everything else
    __block XCTestExpectation *networkExpectation = [self expectationWithDescription:@"network"];
    NSURLSessionDataTask *basicGetTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        XCTAssertNotNil(data);
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        XCTAssertNil(error);
        XCTAssertEqualObjects(dataDict[@"args"], @{@"test" : @"test"});
        // Now this ensures that the recording returned is the stub and not an accidental "live" request. This is
        // important for stable testing
        XCTAssertEqualObjects([(NSHTTPURLResponse *)response allHeaderFields][@"Date"], @"Wed, 02 Mar 2016 18:09:28 GMT");
        // fulfill the expectation
        [networkExpectation fulfill];
    }];
    [basicGetTask resume];
    // explicitly wait for the expectation
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        // Assert fail if timeout encounters an error
        XCTAssertNil(error);
    }];
}

@end

```

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

## Notes

BeKindRewind will only record network events if the NSURLSessionTask is sent a `resume` message. When NSURLSessionTask objects are created, they are in a NSURLSessionTaskStateSuspended and will not start recording until the `resume` is sent. Once the `resume` is sent, it will record everything until the end of the test (protected by your XCTestExpectation

It is recommended you use the BKRTestVCR subclass for recording. It automatically handles issues around asynchronous execution and XCTestCase.

By default, BeKindRewind expects a Property List fixture to exist for every test case when it is playing back (mocking) network activity. If no fixture exists, then an exception is thrown. This can be overridden in the BKRTestConfiguration (or it's super class BKRConfiguration) object.

If you see an exception during testing similar to `*** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'API violation - creating expectations while already in waiting mode.'` then you probably need to adjust your `BKRTestConfiguration` object. The default constructor for `BKRTestConfiguration` (`defaultConfigurationWithTestCase:`) calls a block when a network action begins and ends to create an `XCTestExpectation` around a network action so that the recording is not clipped. If you have a series of network actions that are triggered during a test, some of which occur after the `waitForExpectationsWithTimeout: handler:` is called, then you should set these blocks to nil for the duration of that test case. This should be overridden in your `BKRTestCase` subclass (or wherever is appropriate if you are implementing a `BKRVCR` yourself. An example of overriding this in `BKRTestCase` is below:

```objective-c
- (BKRTestConfiguration *)testConfiguration {
    BKRTestConfiguration *defaultConfiguration = [super testConfiguration];
    defaultConfiguration.beginRecordingBlock = nil;
    defaultConfiguration.endRecordingBlock = nil;
    return defaultConfiguration;
}
```

If you see test failures due to an asynchronous wait timeout for an XCTestExpectation named `reset` then that is most likely due to the test case trying to stub requests while removing stubs. The failure will look something like this:
```
[21:32:10]: ▸ ✗ testCopyConfigurationWithSubscribedChannelsAndCallbackQueue, ((error) == nil) failed: "Error Domain=com.apple.XCTestErrorDomain Code=0 "The operation couldn’t be completed. (com.apple.XCTestErrorDomain error 0.)""
[21:32:10]: ▸ ✗ testCopyConfigurationWithSubscribedChannelsAndCallbackQueue, Asynchronous wait failed: Exceeded timeout of 60 seconds, with unfulfilled expectations: "reset".
```

In order to fix this, make sure to properly tear down and stop any long running or background processes that are asynchronous, especially those related to networking, so that this race condition isn't introduced into your testing.

## Basic Testing Strategy

Try to avoid writing a test that is dependent upon state. Instead, ensure that when `isRecording == YES` that the test can be fully recorded for playback, including setUp and tearDown. This eases development and ensures that the test isn't written on a condition that wouldn't be recreated when another developer tries to update your test with a new recording.

## Support for iOS 7

Use version 0.6.x or lower of [JSZVCR](https://github.com/jzucker2/JSZVCR.git) if you want to test against iOS 7 or lower.

## Author

Jordan Zucker, jordan.zucker@gmail.com

## License

BeKindRewind is available under the MIT license. See the [LICENSE](https://github.com/jzucker2/BeKindRewind/blob/master/LICENSE) file for more info.

## Future features
* Swift tests (at least basic)
* Swift Package Manager
* Small tutorial to show how to drag in recordings to the project
* explain fixture write directory hack for easy recording (and fix and add tests)
* Separate into subspecs
* add code coverage
* test different types of errors (timeout, invalid url) for playing/recording
* Tests for different types of NSURLSession (shared, ephemeral, standard, background, etc). Make different test case classes for each type of session
* afnetworking tests
* test for other types of network requests (streaming)
* blog post
* JSON serializing in addition to plist serializing
* tests for matcher classes
* investigate possible reset bug
