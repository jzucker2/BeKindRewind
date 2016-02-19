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
#import "XCTestCase+BKRHelpers.h"

@interface BKRPlayableVCRTestCase : BKRBaseTestCase
@property (nonatomic, copy) NSString *testPlayingFilePath;
@property (nonatomic, strong) BKRPlayableVCR *vcr;
@end

@implementation BKRPlayableVCRTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSString *fileName = [NSStringFromSelector(self.invocation.selector) stringByAppendingPathExtension:@"plist"];
    XCTAssertNotNil(fileName);
    self.testPlayingFilePath = [BKRFilePathHelper findPathForFile:fileName inBundleForClass:self.class];
    XCTAssertNotNil(self.testPlayingFilePath);
    XCTAssertTrue([BKRFilePathHelper filePathExists:self.testPlayingFilePath]);
    
    NSDictionary *cassetteDictionary = [BKRFilePathHelper dictionaryForPlistFilePath:self.testPlayingFilePath];
    XCTAssertNotNil(cassetteDictionary);
    
    self.vcr = [BKRPlayableVCR vcrWithMatcherClass:[BKRPlayheadMatcher class]];
    
    [self insertCassetteFilePath:self.testPlayingFilePath intoVCR:self.vcr];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self resetVCR:self.vcr];
    [super tearDown];
}

// the fixture for this exists, and is asserted in the setUp
- (void)testNoMockingWhenVCRIsNotSentPlay {
    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
}

- (void)testOffThenOn {
    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
    expectedResult.isRecording = NO;
    [self playVCR:self.vcr];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
}

- (void)testOnThenOff {
    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:NO];
    [self playVCR:self.vcr];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
    expectedResult.isRecording = YES;
    [self stopVCR:self.vcr];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
}

- (void)testPlayingOneGETRequest {
    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:NO];
    [self playVCR:self.vcr];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
}

- (void)testPlayingOneCancelledGETRequest {
    BKRTestExpectedResult *cancelledRequest = [self HTTPBinCancelledRequestWithRecording:NO];
    [self playVCR:self.vcr];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[cancelledRequest] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
}

- (void)testPlayingOnePOSTRequest {
    BKRTestExpectedResult *postResult = [self HTTPBinPostRequestWithRecording:NO];
    [self playVCR:self.vcr];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[postResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
}

- (void)testPlayingMultipleGETRequests {
    BKRTestExpectedResult *firstResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:NO];
    BKRTestExpectedResult *secondResult = [self HTTPBinGetRequestWithQueryString:@"test=test2" withRecording:NO];
    [self playVCR:self.vcr];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[firstResult, secondResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
}

- (void)testPlayingTwoConsecutiveGETRequestsWithSameRequestURLAndDifferentResponses {
    BKRTestExpectedResult *firstResult = [self PNGetTimeTokenWithRecording:NO];
    BKRTestExpectedResult *secondResult = [self PNGetTimeTokenWithRecording:NO];
    
    [self playVCR:self.vcr];
    
    [self BKRTest_executePNTimeTokenNetworkCallsForExpectedResults:@[firstResult, secondResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
//    NSString *getTaskURLString = @"https://pubsub.pubnub.com/time/0";
//    __block XCTestExpectation *playExpectation = [self expectationWithDescription:@"start playing expectation"];
//    [self.vcr playWithCompletionBlock:^{
//        [playExpectation fulfill];
//        playExpectation = nil;
//    }];
//    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
//        XCTAssertNil(error);
//    }];
////    BKRWeakify(self);
//    __block NSNumber *firstTimetoken = nil;
//    [self getTaskWithURLString:getTaskURLString taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//        // ensure that result from network is as expected
//        XCTAssertNotNil(dataArray);
//        firstTimetoken = dataArray.firstObject;
//        XCTAssertNotNil(firstTimetoken);
//        XCTAssertTrue([firstTimetoken isKindOfClass:[NSNumber class]]);
//        NSTimeInterval firstTimeTokenAsUnix = [self unixTimestampForPubNubTimetoken:firstTimetoken];
//        NSTimeInterval currentUnixTimestamp = [[NSDate date] timeIntervalSince1970];
//        XCTAssertNotEqualWithAccuracy(firstTimeTokenAsUnix, currentUnixTimestamp, 5);
//        
//        NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse *)response;
//        XCTAssertEqual(castedResponse.statusCode, 200);
//        XCTAssertEqualObjects(castedResponse.allHeaderFields[@"Date"], @"Fri, 12 Feb 2016 00:29:20 GMT", @"actual received response is different");
//        
//    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
//        
//    }];
//    
//    [self getTaskWithURLString:getTaskURLString taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//        // ensure that result from network is as expected
//        XCTAssertNotNil(dataArray);
//        NSNumber *secondTimetoken = dataArray.firstObject;
//        XCTAssertNotNil(secondTimetoken);
//        XCTAssertTrue([secondTimetoken isKindOfClass:[NSNumber class]]);
//        NSTimeInterval secondTimeTokenAsUnix = [self unixTimestampForPubNubTimetoken:secondTimetoken];
//        NSTimeInterval currentUnixTimestamp = [[NSDate date] timeIntervalSince1970];
//        XCTAssertNotEqualWithAccuracy(secondTimeTokenAsUnix, currentUnixTimestamp, 5);
//        // also make sure that the two time tokens returned are different
//        XCTAssertNotEqualObjects(firstTimetoken, secondTimetoken);
//        
//        NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse *)response;
//        XCTAssertEqual(castedResponse.statusCode, 200);
//        XCTAssertEqualObjects(castedResponse.allHeaderFields[@"Date"], @"Fri, 12 Feb 2016 00:29:21 GMT", @"actual received response is different");
//        
//    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
//        
//    }];
}

@end
