//
//  BKRPlayingWithRecordedTimingTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 4/15/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRTestConfiguration.h>
#import <BeKindRewind/BKRTestCase.h>
#import <BeKindRewind/BKRCassette.h>
#import <BeKindRewind/BKRPlayheadWithTimingMatcher.h>
#import "XCTestCase+BKRHelpers.h"

@interface BKRPlayingWithRecordedTimingTestCase : BKRTestCase

@end

@implementation BKRPlayingWithRecordedTimingTestCase

- (BOOL)isRecording {
    return NO;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    XCTAssertNotNil(self.currentVCR);
    XCTAssertTrue([[self.currentVCR matcher] isKindOfClass:[BKRPlayheadWithTimingMatcher class]]);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (BKRTestConfiguration *)testConfiguration {
    BKRTestConfiguration *configuration = [super testConfiguration];
    configuration.matcherClass = [BKRPlayheadWithTimingMatcher class];
    return configuration;
}

- (void)testPlayingOneGETRequest {
    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:NO];
    expectedResult.shouldAssertOnTiming = YES;
    
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions([[self.currentVCR currentCassette] allScenes]);
    }];
}

- (void)testPlayingOneCancelledGETRequest {
    BKRTestExpectedResult *cancelledRequest = [self HTTPBinCancelledRequestWithRecording:NO];
    cancelledRequest.shouldAssertOnTiming = YES;
    
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[cancelledRequest] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions([[self.currentVCR currentCassette] allScenes]);
    }];
}

- (void)testPlayingOnePOSTRequest {
    BKRTestExpectedResult *postResult = [self HTTPBinPostRequestWithRecording:NO];
    postResult.shouldAssertOnTiming = YES;
    
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[postResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions([[self.currentVCR currentCassette] allScenes]);
    }];
}

- (void)testPlayingMultipleGETRequests {
    BKRTestExpectedResult *firstResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:NO];
    firstResult.shouldAssertOnTiming = YES;
    BKRTestExpectedResult *secondResult = [self HTTPBinGetRequestWithQueryString:@"test=test2" withRecording:NO];
    secondResult.shouldAssertOnTiming = YES;
    
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[firstResult, secondResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions([[self.currentVCR currentCassette] allScenes]);
    }];
}

- (void)testPlayingTwoConsecutiveGETRequestsWithSameRequestURLAndDifferentResponses {
    BKRTestExpectedResult *firstResult = [self PNGetTimeTokenWithRecording:NO];
    firstResult.shouldAssertOnTiming = YES;
    BKRTestExpectedResult *secondResult = [self PNGetTimeTokenWithRecording:NO];
    secondResult.shouldAssertOnTiming = YES;
    
    [self BKRTest_executePNTimeTokenNetworkCallsForExpectedResults:@[firstResult, secondResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions([[self.currentVCR currentCassette] allScenes]);
    }];
}

- (void)testPlayingTwoSimultaneousGETRequests {
    BKRTestExpectedResult *firstResult = [self HTTPBinSimultaneousDelayedRequestWithDelay:2 withRecording:NO];
    firstResult.shouldAssertOnTiming = YES;
    BKRTestExpectedResult *secondResult = [self HTTPBinSimultaneousDelayedRequestWithDelay:3 withRecording:NO];
    secondResult.shouldAssertOnTiming = YES;
    
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[firstResult, secondResult] simultaneously:YES withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions([[self.currentVCR currentCassette] allScenes]);
    }];
}

- (void)testPlayingChunkedDataRequest {
    BKRTestExpectedResult *expectedResult = [self HTTPBinDripDataWithRecording:NO];
    expectedResult.shouldAssertOnTiming = YES;
    
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions([[self.currentVCR currentCassette] allScenes]);
    }];
}

- (void)testPlayingRedirectRequest {
    BKRTestExpectedResult *expectedResult = [self HTTPBinRedirectWithRecording:NO];
    expectedResult.shouldAssertOnTiming = YES;
    
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions([[self.currentVCR currentCassette] allScenes]);
    }];
}

@end
