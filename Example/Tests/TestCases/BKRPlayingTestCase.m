//
//  BKRPlayingTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/22/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRTestCase.h>
#import "XCTestCase+BKRHelpers.h"

@interface BKRPlayingTestCase : BKRTestCase

@end

@implementation BKRPlayingTestCase

- (BOOL)isRecording {
    return NO;
}

//// the fixture for this exists, and is asserted in the setUp
//- (void)testPlayingNoMockingWhenVCRIsNotSentPlay {
//    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//    }];
//}
//
//- (void)testPlayingOffThenOn {
//    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//    }];
//    expectedResult.isRecording = NO; // flip expected result to not recording for asserts
//    [self playTestVCR:self.vcr];
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//    }];
//}
//
//- (void)testPlayingOnThenOff {
//    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:NO];
//    [self playTestVCR:self.vcr];
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//    }];
//    expectedResult.isRecording = YES; // flip expected result to recording for asserts
//    [self stopTestVCR:self.vcr];
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//    }];
//}

- (void)testPlayingOneGETRequest {
    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:NO];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
}

//- (void)testPlayingOneCancelledGETRequest {
//    BKRTestExpectedResult *cancelledRequest = [self HTTPBinCancelledRequestWithRecording:NO];
//    [self playTestVCR:self.vcr];
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[cancelledRequest] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//    }];
//}
//
//- (void)testPlayingOnePOSTRequest {
//    BKRTestExpectedResult *postResult = [self HTTPBinPostRequestWithRecording:NO];
//    [self playTestVCR:self.vcr];
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[postResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//    }];
//}
//
//- (void)testPlayingMultipleGETRequests {
//    BKRTestExpectedResult *firstResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:NO];
//    BKRTestExpectedResult *secondResult = [self HTTPBinGetRequestWithQueryString:@"test=test2" withRecording:NO];
//    [self playTestVCR:self.vcr];
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[firstResult, secondResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//    }];
//}
//
//- (void)testPlayingTwoConsecutiveGETRequestsWithSameRequestURLAndDifferentResponses {
//    BKRTestExpectedResult *firstResult = [self PNGetTimeTokenWithRecording:NO];
//    BKRTestExpectedResult *secondResult = [self PNGetTimeTokenWithRecording:NO];
//    
//    [self playTestVCR:self.vcr];
//    
//    [self BKRTest_executePNTimeTokenNetworkCallsForExpectedResults:@[firstResult, secondResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//    }];
//}

@end
