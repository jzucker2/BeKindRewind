//
//  BKRRecorderTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 2/24/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRRecorder.h>
#import "XCTestCase+BKRHelpers.h"
#import "BKRBaseTestCase.h"

// remove these two after
#import <BeKindRewind/BKRScene.h>
#import <BeKindRewind/BKRFrame.h>
#import <BeKindRewind/BKRResponseFrame.h>
#import <BeKindRewind/BKRRequestFrame.h>
#import <BeKindRewind/BKRDataFrame.h>

@interface BKRRecorderTestCase : BKRBaseTestCase

@end

@implementation BKRRecorderTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [self insertNewCassetteInRecorder];
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
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] simultaneously:NO withTaskCompletionAssertions:nil taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 0);
    }];
}

- (void)testNotRecordingGETRequestWhenRecorderIsExplicitlyDisabled {
    [self setRecorderToEnabledWithExpectation:NO];
    
    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] simultaneously:NO withTaskCompletionAssertions:nil taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 0);
    }];
}

- (void)testRecordingOneGETRequest {
    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] simultaneously:NO withTaskCompletionAssertions:nil taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions([BKRRecorder sharedInstance].allScenes);
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
        NSLog(@"++++++++++++++++");
        NSLog(@"%@", [BKRRecorder sharedInstance].allScenes);
        BKRScene *scene = [BKRRecorder sharedInstance].allScenes.firstObject;
        NSLog(@"%@", scene.allFrames);
        for (BKRResponseFrame *frame in scene.allResponseFrames) {
            NSLog(@"&&&&&&&&&&&&&&&");
            NSLog(@"response: %@", frame.debugDescription);
            NSLog(@"&&&&&&&&&&&&&&&");
        }
        for (BKRRequestFrame *frame in scene.allRequestFrames) {
            NSLog(@"&&&&&&&&&&&&&&&");
            NSLog(@"request: %@", frame.debugDescription);
            NSLog(@"&&&&&&&&&&&&&&&");
        }
        NSLog(@"++++++++++++++++");
    }];
}

- (void)testSwitchRecordingOffThenOn {
    [self setRecorderToEnabledWithExpectation:NO];
    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] simultaneously:NO withTaskCompletionAssertions:nil taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 0);
    }];
    
    [self setRecorderToEnabledWithExpectation:YES];
    
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] simultaneously:NO withTaskCompletionAssertions:nil taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions([BKRRecorder sharedInstance].allScenes);
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
}

- (void)testSwitchRecordingOnThenOff {
    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] simultaneously:NO withTaskCompletionAssertions:nil taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions([BKRRecorder sharedInstance].allScenes);
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
    
    [self setRecorderToEnabledWithExpectation:NO];
    
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] simultaneously:NO withTaskCompletionAssertions:nil taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
}

- (void)testRecordingOneCancelledGETRequest {
    BKRTestExpectedResult *cancelledResult = [self HTTPBinCancelledRequestWithRecording:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[cancelledResult] simultaneously:NO withTaskCompletionAssertions:nil taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions([BKRRecorder sharedInstance].allScenes);
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
}

- (void)testRecordingOnePOSTRequest {
    BKRTestExpectedResult *expectedResult = [self HTTPBinPostRequestWithRecording:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] simultaneously:NO withTaskCompletionAssertions:nil taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions([BKRRecorder sharedInstance].allScenes);
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
}

- (void)testRecordingMultipleGETRequests {
    BKRTestExpectedResult *firstResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    BKRTestExpectedResult *secondResult = [self HTTPBinGetRequestWithQueryString:@"test=test2" withRecording:YES];
    
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[firstResult] simultaneously:NO withTaskCompletionAssertions:nil taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
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
            NSLog(@"scenes: %@", [BKRRecorder sharedInstance].allScenes);
            for (BKRScene *scene in [BKRRecorder sharedInstance].allScenes) {
                NSLog(@"scene (%@): %@", scene, scene.allFrames);
            }
        } else {
            XCTFail(@"how did we get here?");
        }
    }];
}

- (void)testRecordingTwoSimultaneousGETRequests {
    BKRTestExpectedResult *firstResult = [self HTTPBinSimultaneousDelayedRequestWithDelay:2 withRecording:YES];
    BKRTestExpectedResult *secondResult = [self HTTPBinSimultaneousDelayedRequestWithDelay:3 withRecording:YES];
    
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[firstResult, secondResult] simultaneously:YES withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions([BKRRecorder sharedInstance].allScenes);
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 2);
    }];
}

- (void)DISABLE_testRecordingRedirectRequest {
    BKRTestExpectedResult *expectedResult = [self HTTPBinRedirectWithRecording:YES];
    
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"-------------------");
        NSLog(@"result: %@", result);
        NSLog(@"task: %@", task);
        NSLog(@"task.originalRequest: %@", task.originalRequest);
        NSLog(@"task.currentRequest: %@", task.currentRequest);
        NSLog(@"task.currentRequest.allHTTPHeaderFields: %@", task.currentRequest.allHTTPHeaderFields);
        NSLog(@"data: %@", data);
        NSLog(@"response: %@", response);
        NSLog(@"-------------------");
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        NSLog(@"++++++++++++++++");
        NSLog(@"%@", [BKRRecorder sharedInstance].allScenes);
        BKRScene *scene = [BKRRecorder sharedInstance].allScenes.firstObject;
        NSLog(@"%@", scene.allFrames);
        NSLog(@"%@", scene.allFrames);
//        for (BKRResponseFrame *frame in scene.allResponseFrames) {
//            NSLog(@"&&&&&&&&&&&&&&&");
//            NSLog(@"response: %@", frame.debugDescription);
//            NSLog(@"&&&&&&&&&&&&&&&");
//        }
//        for (BKRRequestFrame *frame in scene.allRequestFrames) {
//            NSLog(@"&&&&&&&&&&&&&&&");
//            NSLog(@"request: %@", frame.debugDescription);
//            NSLog(@"&&&&&&&&&&&&&&&");
//        }
        for (BKRFrame *frame in scene.allFrames) {
            NSLog(@"&&&&&&&&&&&&&&&");
            NSLog(@"frame: %@", frame.debugDescription);
            NSLog(@"&&&&&&&&&&&&&&&");
        }
        NSLog(@"++++++++++++++++");
        batchSceneAssertions([BKRRecorder sharedInstance].allScenes);
    }];
}

- (void)testRecordingChunkedDataRequest {
    BKRTestExpectedResult *expectedResult = [self HTTPBinDripDataWithRecording:YES];
    
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"-------------------");
        NSLog(@"result: %@", result);
        NSLog(@"task: %@", task);
        NSLog(@"task.originalRequest: %@", task.originalRequest);
        NSLog(@"task.currentRequest: %@", task.currentRequest);
        NSLog(@"data: %@", data);
        NSLog(@"response: %@", response);
        NSLog(@"-------------------");
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        NSLog(@"++++++++++++++++");
        NSLog(@"%@", [BKRRecorder sharedInstance].allScenes);
        BKRScene *scene = [BKRRecorder sharedInstance].allScenes.firstObject;
        NSLog(@"%@", scene.allFrames);
        for (BKRFrame *frame in scene.allFrames) {
            NSLog(@"&&&&&&&&&&&&&&&");
            NSLog(@"frame: %@", frame.debugDescription);
            NSLog(@"&&&&&&&&&&&&&&&");
        }
//        for (BKRRequestFrame *frame in scene.allRequestFrames) {
//            NSLog(@"&&&&&&&&&&&&&&&");
//            NSLog(@"request: %@", frame.debugDescription);
//            NSLog(@"&&&&&&&&&&&&&&&");
//        }
//        NSLog(@"&&&&&&&&&&&&&&&");
//        NSLog(@"data: %@", scene.allDataFrames.firstObject.JSONConvertedObject);
//        NSLog(@"&&&&&&&&&&&&&&&");
        NSLog(@"++++++++++++++++");
        batchSceneAssertions([BKRRecorder sharedInstance].allScenes);
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
}

@end
