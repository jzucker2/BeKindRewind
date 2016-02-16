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
    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test"];
    [self BKRTest_executeHTTPBinNetworkCallWithExpectedResult:expectedResult withTaskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 0);
    }];
}

- (void)testNotRecordingGETRequestWhenRecorderIsExplicitlyDisabled {
    [self setRecorderToEnabledWithExpectation:NO];
    BKRTestExpectedResult *result = [self HTTPBinGetRequestWithQueryString:@"test=test"];
    [self BKRTest_executeHTTPBinNetworkCallWithExpectedResult:result withTaskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 0);
    }];
}

- (void)testRecordingOneGETRequest {
    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test"];
    [self BKRTest_executeHTTPBinNetworkCallWithExpectedResult:expectedResult withTaskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
}

- (void)testSwitchRecordingOffThenOn {
    [self setRecorderToEnabledWithExpectation:NO];
    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test"];
    [self BKRTest_executeHTTPBinNetworkCallWithExpectedResult:expectedResult withTaskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 0);
    }];
    
    [self setRecorderToEnabledWithExpectation:YES];
    
    [self BKRTest_executeHTTPBinNetworkCallWithExpectedResult:expectedResult withTaskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
}

- (void)testSwitchRecordingOnThenOff {
    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test"];
    [self BKRTest_executeHTTPBinNetworkCallWithExpectedResult:expectedResult withTaskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
    
    [self setRecorderToEnabledWithExpectation:NO];
    
    [self BKRTest_executeHTTPBinNetworkCallWithExpectedResult:expectedResult withTaskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
}

- (void)testRecordingOneCancelledGETRequest {
    BKRTestExpectedResult *cancelledResult = [self HTTPBinCancelledRequest];
    [self BKRTest_executeHTTPBinNetworkCallWithExpectedResult:cancelledResult withTaskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
}

- (void)testRecordingOnePOSTRequest {
    BKRTestExpectedResult *result = [self HTTPBinPostRequest];
    [self BKRTest_executeHTTPBinNetworkCallWithExpectedResult:result withTaskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
}

- (void)testRecordingMultipleGETRequests {
    BKRTestExpectedResult *firstResult = [self HTTPBinGetRequestWithQueryString:@"test=test"];
    
    BKRTestExpectedResult *secondResult = [self HTTPBinGetRequestWithQueryString:@"test=test2"];
    
    [self BKRTest_executeHTTPBinNetworkCallWithExpectedResult:firstResult withTaskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
    
    [self BKRTest_executeHTTPBinNetworkCallWithExpectedResult:secondResult withTaskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 2);
    }];
}

//- (void)testRecordingTwoConsecutiveGETRequestsWithSameRequestURLAndDifferentResponses {
//    BKRExpectedRecording *firstRecording = [BKRExpectedRecording recording];
//    firstRecording.URLString = @"https://pubsub.pubnub.com/time/0";
//    firstRecording.responseStatusCode = 200;
//    firstRecording.expectedSceneNumber = 0;
//    firstRecording.expectedNumberOfFrames = 4;
//    
//    BKRExpectedRecording *secondRecording = [BKRExpectedRecording recording];
//    secondRecording.URLString = firstRecording.URLString;
//    secondRecording.responseStatusCode = 200;
//    secondRecording.expectedSceneNumber = 1;
//    secondRecording.expectedNumberOfFrames = 4;
//    
//    __block NSNumber *firstTimetoken = nil;
//    [self recordingTaskWithExpectedRecording:firstRecording taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//        // ensure that result from network is as expected
//        XCTAssertNotNil(dataArray);
//        firstTimetoken = dataArray.firstObject;
//        XCTAssertNotNil(firstTimetoken);
//        XCTAssertTrue([firstTimetoken isKindOfClass:[NSNumber class]]);
//        NSTimeInterval firstTimeTokenAsUnix = [self unixTimestampForPubNubTimetoken:firstTimetoken];
//        NSTimeInterval currentUnixTimestamp = [[NSDate date] timeIntervalSince1970];
//        XCTAssertEqualWithAccuracy(firstTimeTokenAsUnix, currentUnixTimestamp, 5);
//    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
//        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
//    }];
//    
//    [self recordingTaskWithExpectedRecording:secondRecording taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//        // ensure that result from network is as expected
//        XCTAssertNotNil(dataArray);
//        NSNumber *secondTimetoken = dataArray.firstObject;
//        XCTAssertNotNil(secondTimetoken);
//        XCTAssertTrue([secondTimetoken isKindOfClass:[NSNumber class]]);
//        NSTimeInterval secondTimeTokenAsUnix = [self unixTimestampForPubNubTimetoken:secondTimetoken];
//        NSTimeInterval currentUnixTimestamp = [[NSDate date] timeIntervalSince1970];
//        XCTAssertEqualWithAccuracy(secondTimeTokenAsUnix, currentUnixTimestamp, 5);
//        // also make sure that the two time tokens returned are different
//        XCTAssertNotEqualObjects(firstTimetoken, secondTimetoken);
//    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
//        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 2);
//    }];
//}

@end
