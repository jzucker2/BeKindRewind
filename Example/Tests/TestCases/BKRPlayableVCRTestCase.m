//
//  BKRPlayableVCRTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 2/11/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRPlayableVCR.h>
#import <BeKindRewind/BKRFilePathHelper.h>
#import <BeKindRewind/BKRPlayheadMatcher.h>
#import "BKRBaseTestCase.h"
#import "XCTestCase+BKRAdditions.h"

@interface BKRPlayableVCRTestCase : BKRBaseTestCase
@property (nonatomic, copy) NSString *testRecordingFilePath;
@property (nonatomic, strong) BKRPlayableVCR *vcr;
@end

@implementation BKRPlayableVCRTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSString *fileName = [NSStringFromSelector(self.invocation.selector) stringByAppendingPathExtension:@"plist"];
    XCTAssertNotNil(fileName);
    self.testRecordingFilePath = [BKRFilePathHelper findPathForFile:fileName inBundleForClass:self.class];
    XCTAssertNotNil(self.testRecordingFilePath);
    XCTAssertTrue([BKRFilePathHelper filePathExists:self.testRecordingFilePath]);
    
    NSDictionary *cassetteDictionary = [BKRFilePathHelper dictionaryForPlistFilePath:self.testRecordingFilePath];
    XCTAssertNotNil(cassetteDictionary);
    
    self.vcr = [BKRPlayableVCR vcrWithMatcherClass:[BKRPlayheadMatcher class]];
    XCTAssertNotNil(self.vcr);
    
    __block XCTestExpectation *insertExpectation = [self expectationWithDescription:@"insert expectation"];
    XCTAssertTrue([self.vcr insert:self.testRecordingFilePath completionHandler:^(BOOL result, NSString *filePath) {
        [insertExpectation fulfill];
        insertExpectation = nil;
    }]);
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
//    self.vcr.beforeAddingStubsBlock = nil;
//    self.vcr.afterAddingStubsBlock = nil;
    __block XCTestExpectation *resetExpectation = [self expectationWithDescription:@"reset expectation"];
    [self.vcr resetWithCompletionBlock:^{
        [resetExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
//        if (error) {
//            XCTFail(@"%@", error.localizedDescription);
//        }
    }];
//    self.vcr.beforeAddingStubsBlock = nil;
//    self.vcr.afterAddingStubsBlock = nil;
//    [self.vcr resetWithCompletionBlock:nil];
    [super tearDown];
}

// the fixture for this exists, and is asserted in the setUp
// this fixture is an exact copy of `testPlayingOneGETRequest` so assert that the date is different, because rest of the test should be about the same
- (void)testNoMockingWhenVCRIsNotSentPlay {
    BKRWeakify(self);
    [self getTaskWithURLString:@"https://httpbin.org/get?test=test" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        BKRStrongify(self);
        XCTAssertNotNil(data);
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        // ensure that result from network is as expected
        XCTAssertEqualObjects(dataDict[@"args"], @{@"test": @"test"});
        NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse *)response;
        XCTAssertEqual(castedResponse.statusCode, 200);
        XCTAssertNotNil(castedResponse.allHeaderFields[@"Date"]);
        XCTAssertNotEqualObjects(castedResponse.allHeaderFields[@"Date"], @"Fri, 12 Feb 2016 00:29:20 GMT", @"actual received response is different");
        
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        
    }];
}

- (void)testOffThenOn {
    NSString *expectedHeaderFieldDateString = @"Fri, 12 Feb 2016 23:27:29 GMT";
    BKRWeakify(self);
    [self getTaskWithURLString:@"https://httpbin.org/get?test=test" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        BKRStrongify(self);
        XCTAssertNotNil(data);
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        // ensure that result from network is as expected
        XCTAssertEqualObjects(dataDict[@"args"], @{@"test": @"test"});
        NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse *)response;
        XCTAssertEqual(castedResponse.statusCode, 200);
        XCTAssertNotNil(castedResponse.allHeaderFields[@"Date"]);
        XCTAssertNotEqualObjects(castedResponse.allHeaderFields[@"Date"], expectedHeaderFieldDateString, @"actual received response is different");
        
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        
    }];
    
    __block XCTestExpectation *playExpectation = [self expectationWithDescription:@"start playing expectation"];
    [self.vcr playWithCompletionBlock:^{
        [playExpectation fulfill];
        playExpectation = nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    
    [self getTaskWithURLString:@"https://httpbin.org/get?test=test" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        BKRStrongify(self);
        XCTAssertNotNil(data);
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        // ensure that result from network is as expected
        XCTAssertEqualObjects(dataDict[@"args"], @{@"test": @"test"});
        NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse *)response;
        XCTAssertEqual(castedResponse.statusCode, 200);
        XCTAssertEqualObjects(castedResponse.allHeaderFields[@"Date"], expectedHeaderFieldDateString, @"actual received response is different");
        
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        
    }];
}

- (void)testOnThenOff {
    NSString *expectedHeaderFieldDateString = @"Fri, 12 Feb 2016 23:27:29 GMT";
    __block XCTestExpectation *playExpectation = [self expectationWithDescription:@"start playing expectation"];
    [self.vcr playWithCompletionBlock:^{
        [playExpectation fulfill];
        playExpectation = nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    BKRWeakify(self);
    [self getTaskWithURLString:@"https://httpbin.org/get?test=test" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        BKRStrongify(self);
        XCTAssertNotNil(data);
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        // ensure that result from network is as expected
        XCTAssertEqualObjects(dataDict[@"args"], @{@"test": @"test"});
        NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse *)response;
        XCTAssertEqual(castedResponse.statusCode, 200);
        XCTAssertEqualObjects(castedResponse.allHeaderFields[@"Date"], expectedHeaderFieldDateString, @"actual received response is different");
        
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        
    }];
    
    __block XCTestExpectation *stopExpectation = [self expectationWithDescription:@"stop playing expectation"];
    [self.vcr stopWithCompletionBlock:^{
        [stopExpectation fulfill];
        stopExpectation = nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    
    [self getTaskWithURLString:@"https://httpbin.org/get?test=test" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        BKRStrongify(self);
        XCTAssertNotNil(data);
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        // ensure that result from network is as expected
        XCTAssertEqualObjects(dataDict[@"args"], @{@"test": @"test"});
        NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse *)response;
        XCTAssertEqual(castedResponse.statusCode, 200);
        XCTAssertNotNil(castedResponse.allHeaderFields[@"Date"]);
        XCTAssertNotEqualObjects(castedResponse.allHeaderFields[@"Date"], expectedHeaderFieldDateString, @"actual received response is different");
        
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        
    }];
}

- (void)testPlayingOneGETRequest {
    __block XCTestExpectation *playExpectation = [self expectationWithDescription:@"start playing expectation"];
    [self.vcr playWithCompletionBlock:^{
        [playExpectation fulfill];
        playExpectation = nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    BKRWeakify(self);
    [self getTaskWithURLString:@"https://httpbin.org/get?test=test" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        BKRStrongify(self);
        XCTAssertNotNil(data);
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        // ensure that result from network is as expected
        XCTAssertEqualObjects(dataDict[@"args"], @{@"test": @"test"});
        NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse *)response;
        XCTAssertEqual(castedResponse.statusCode, 200);
        XCTAssertEqualObjects(castedResponse.allHeaderFields[@"Date"], @"Fri, 12 Feb 2016 00:29:20 GMT", @"actual received response is different");

    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {

    }];
}

- (void)testPlayingOneCancelledGETRequest {
    __block XCTestExpectation *playExpectation = [self expectationWithDescription:@"start playing expectation"];
    [self.vcr playWithCompletionBlock:^{
        [playExpectation fulfill];
        playExpectation = nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
//    BKRWeakify(self);
    [self cancellingGetTaskWithURLString:@"https://httpbin.org/delay/10" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertEqual(error.code, -999);
        XCTAssertEqualObjects(error.domain, NSURLErrorDomain);
        NSDictionary *expectedErrorUserInfo = @{
                                                NSURLErrorFailingURLErrorKey: [NSURL URLWithString:@"https://httpbin.org/delay/10"],
                                                NSURLErrorFailingURLStringErrorKey: @"https://httpbin.org/delay/10",
                                                NSLocalizedDescriptionKey: @"cancelled"
                                                };
        XCTAssertEqualObjects(error.userInfo, expectedErrorUserInfo);
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        
    }];
}

- (void)testPlayingOnePOSTRequest {
    __block XCTestExpectation *playExpectation = [self expectationWithDescription:@"start playing expectation"];
    [self.vcr playWithCompletionBlock:^{
        [playExpectation fulfill];
        playExpectation = nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    
    NSDictionary *sendingJSON = @{@"foo":@"bar"};
    
    [self postJSON:sendingJSON withURLString:@"https://httpbin.org/post" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(data);
        // ensure that data returned is same as data posted
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSDictionary *formDict = dataDict[@"form"];
        // for this service, need to fish out the data sent
        NSArray *formKeys = formDict.allKeys;
        NSString *rawReceivedDataString = formKeys.firstObject;
        NSDictionary *receivedDataDictionary = [NSJSONSerialization JSONObjectWithData:[rawReceivedDataString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        // ensure that result from network is as expected
        XCTAssertEqualObjects(sendingJSON, receivedDataDictionary);
        
        NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse *)response;
        XCTAssertEqual(castedResponse.statusCode, 200);
        XCTAssertEqualObjects(castedResponse.allHeaderFields[@"Date"], @"Fri, 12 Feb 2016 00:29:20 GMT", @"actual received response is different");
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        
    }];
}

- (void)testPlayingMultipleGETRequests {
    __block XCTestExpectation *playExpectation = [self expectationWithDescription:@"start playing expectation"];
    [self.vcr playWithCompletionBlock:^{
        [playExpectation fulfill];
        playExpectation = nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    BKRWeakify(self);
    [self getTaskWithURLString:@"https://httpbin.org/get?test=test" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        BKRStrongify(self);
        XCTAssertNotNil(data);
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        // ensure that result from network is as expected
        XCTAssertEqualObjects(dataDict[@"args"], @{@"test": @"test"});
        NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse *)response;
        XCTAssertEqual(castedResponse.statusCode, 200);
        XCTAssertEqualObjects(castedResponse.allHeaderFields[@"Date"], @"Fri, 12 Feb 2016 00:29:19 GMT", @"actual received response is different");
        
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        
    }];
    
    [self getTaskWithURLString:@"https://httpbin.org/get?test=test2" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        BKRStrongify(self);
        XCTAssertNotNil(data);
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        // ensure that result from network is as expected
        XCTAssertEqualObjects(dataDict[@"args"], @{@"test": @"test2"});
        NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse *)response;
        XCTAssertEqual(castedResponse.statusCode, 200);
        XCTAssertEqualObjects(castedResponse.allHeaderFields[@"Date"], @"Fri, 12 Feb 2016 00:29:19 GMT", @"actual received response is different");
        
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        
    }];
    
    
}

- (void)testPlayingTwoConsecutiveGETRequestsWithSameRequestURLAndDifferentResponses {
    NSString *getTaskURLString = @"https://pubsub.pubnub.com/time/0";
    __block XCTestExpectation *playExpectation = [self expectationWithDescription:@"start playing expectation"];
    [self.vcr playWithCompletionBlock:^{
        [playExpectation fulfill];
        playExpectation = nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
//    BKRWeakify(self);
    __block NSNumber *firstTimetoken = nil;
    [self getTaskWithURLString:getTaskURLString taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        // ensure that result from network is as expected
        XCTAssertNotNil(dataArray);
        firstTimetoken = dataArray.firstObject;
        XCTAssertNotNil(firstTimetoken);
        XCTAssertTrue([firstTimetoken isKindOfClass:[NSNumber class]]);
        NSTimeInterval firstTimeTokenAsUnix = [self unixTimestampForPubNubTimetoken:firstTimetoken];
        NSTimeInterval currentUnixTimestamp = [[NSDate date] timeIntervalSince1970];
        XCTAssertNotEqualWithAccuracy(firstTimeTokenAsUnix, currentUnixTimestamp, 5);
        
        NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse *)response;
        XCTAssertEqual(castedResponse.statusCode, 200);
        XCTAssertEqualObjects(castedResponse.allHeaderFields[@"Date"], @"Fri, 12 Feb 2016 00:29:20 GMT", @"actual received response is different");
        
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        
    }];
    
    [self getTaskWithURLString:getTaskURLString taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        // ensure that result from network is as expected
        XCTAssertNotNil(dataArray);
        NSNumber *secondTimetoken = dataArray.firstObject;
        XCTAssertNotNil(secondTimetoken);
        XCTAssertTrue([secondTimetoken isKindOfClass:[NSNumber class]]);
        NSTimeInterval secondTimeTokenAsUnix = [self unixTimestampForPubNubTimetoken:secondTimetoken];
        NSTimeInterval currentUnixTimestamp = [[NSDate date] timeIntervalSince1970];
        XCTAssertNotEqualWithAccuracy(secondTimeTokenAsUnix, currentUnixTimestamp, 5);
        // also make sure that the two time tokens returned are different
        XCTAssertNotEqualObjects(firstTimetoken, secondTimetoken);
        
        NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse *)response;
        XCTAssertEqual(castedResponse.statusCode, 200);
        XCTAssertEqualObjects(castedResponse.allHeaderFields[@"Date"], @"Fri, 12 Feb 2016 00:29:21 GMT", @"actual received response is different");
        
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        
    }];
}

@end
