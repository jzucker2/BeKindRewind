//
//  BKRRecordingTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/19/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRRecorder.h>
#import <BeKindRewind/BKRCassette+Recordable.h>
#import "XCTestCase+BKRHelpers.h"
#import "BKRBaseTestCase.h"

@interface BKRRecordingTestCase : BKRBaseTestCase
@end

@implementation BKRRecordingTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    BKRCassette *cassette = [BKRCassette cassette];
    [BKRRecorder sharedInstance].currentCassette = cassette;
    if (self.invocation.selector != @selector(testNotRecordingGETRequestWhenRecorderIsNotExplicitlyEnabled)) {
        [self setRecorderToEnabledWithExpectation:YES];
    }

    [self setRecorderBeginAndEndRecordingBlocks];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    __block XCTestExpectation *resetExpectation = [self expectationWithDescription:@"reset expectation"];
    [[BKRRecorder sharedInstance] resetWithCompletionBlock:^{
        [resetExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    [super tearDown];
}

- (void)testNotRecordingGETRequestWhenRecorderIsNotExplicitlyEnabled {
    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:nil taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 0);
    }];
}

- (void)testNotRecordingGETRequestWhenRecorderIsExplicitlyDisabled {
    [self setRecorderToEnabledWithExpectation:NO];
    
    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:nil taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 0);
    }];
}

- (void)testRecordingOneGETRequest {
    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:nil taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions([BKRRecorder sharedInstance].allScenes);
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
}

- (void)testSwitchRecordingOffThenOn {
    [self setRecorderToEnabledWithExpectation:NO];
    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:nil taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 0);
    }];
    
    [self setRecorderToEnabledWithExpectation:YES];
    
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:nil taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions([BKRRecorder sharedInstance].allScenes);
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
}

- (void)testSwitchRecordingOnThenOff {
    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:nil taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions([BKRRecorder sharedInstance].allScenes);
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
    
    [self setRecorderToEnabledWithExpectation:NO];
    
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:nil taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
}

- (void)testRecordingOneCancelledGETRequest {
    BKRTestExpectedResult *cancelledResult = [self HTTPBinCancelledRequestWithRecording:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[cancelledResult] withTaskCompletionAssertions:nil taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions([BKRRecorder sharedInstance].allScenes);
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
}

- (void)testRecordingOnePOSTRequest {
    BKRTestExpectedResult *expectedResult = [self HTTPBinPostRequestWithRecording:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:nil taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions([BKRRecorder sharedInstance].allScenes);
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
}

- (void)testRecordingMultipleGETRequests {
    BKRTestExpectedResult *firstResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    BKRTestExpectedResult *secondResult = [self HTTPBinGetRequestWithQueryString:@"test=test2" withRecording:YES];

    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[firstResult] withTaskCompletionAssertions:nil taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions([BKRRecorder sharedInstance].allScenes);
        if (result == firstResult) {
            XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
        } else if (result == secondResult) {
            XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 2);
        } else {
            XCTFail(@"how did we get here?");
        }
    }];
}

- (void)testRecordingTwoConsecutiveGETRequestsWithSameRequestURLAndDifferentResponses {
    BKRTestExpectedResult *firstResult = [self PNGetTimeTokenWithRecording:YES];
    BKRTestExpectedResult *secondResult = [self PNGetTimeTokenWithRecording:YES];
    
    [self BKRTest_executePNTimeTokenNetworkCallsForExpectedResults:@[firstResult, secondResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions([BKRRecorder sharedInstance].allScenes);
        if (result == firstResult) {
            XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
        } else if (result == secondResult) {
            XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 2);
        } else {
            XCTFail(@"how did we get here?");
        }
    }];
}

@end
