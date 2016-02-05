//
//  BKRRecordingTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/19/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRRecorder.h>
#import <BeKindRewind/BKRRecordableCassette.h>
#import <BeKindRewind/BKRScene.h>
#import <BeKindRewind/BKRDataFrame.h>
#import <BeKindRewind/BKRResponseFrame.h>
#import <BeKindRewind/BKRRequestFrame.h>
#import <BeKindRewind/BKRNSURLSessionConnection.h>
#import <BeKindRewind/BKRNSURLSessionTask.h>
#import <BeKindRewind/NSURLSessionTask+BKRAdditions.h>
#import <BeKindRewind/NSURLSessionTask+BKRTestAdditions.h>
#import "XCTestCase+BKRAdditions.h"
#import "BKRBaseTestCase.h"

@interface BKRRecordingTestCase : BKRBaseTestCase
@end

@implementation BKRRecordingTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [BKRNSURLSessionConnection swizzleNSURLSessionConnection];
    [BKRNSURLSessionTask swizzleNSURLSessionTask];
    BKRRecordableCassette *cassette = [[BKRRecordableCassette alloc] init];
    [BKRRecorder sharedInstance].currentCassette = cassette;
    [BKRRecorder sharedInstance].enabled = YES;

    [BKRRecorder sharedInstance].beginRecordingBlock = ^void(NSURLSessionTask *task) {
        NSString *recordingExpectationString = [NSString stringWithFormat:@"Task: %@", task.globallyUniqueIdentifier];
        task.recordingExpectation = [self expectationWithDescription:recordingExpectationString];
    };
    
    [BKRRecorder sharedInstance].endRecordingBlock = ^void(NSURLSessionTask *task) {
        [task.recordingExpectation fulfill];
    };
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [[BKRRecorder sharedInstance] reset];
    [super tearDown];
}

- (void)testRecordingOneGETRequest {
    BKRExpectedRecording *expectedRecording = [BKRExpectedRecording recording];
    expectedRecording.URLString = @"https://httpbin.org/get?test=test";
    expectedRecording.receivedJSON = @{
                                       @"test": @"test"
                                       };
    expectedRecording.responseStatusCode = 200;
    expectedRecording.expectedSceneNumber = 0;
    expectedRecording.expectedNumberOfFrames = 4;
    [self recordingTaskForHTTPBinWithExpectedRecording:expectedRecording taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
}

- (void)testRecordingOneCancelledGETRequest {
    BKRExpectedRecording *recording = [BKRExpectedRecording recording];
    recording.cancelling = YES;
    recording.URLString = @"https://httpbin.org/delay/10";
    recording.expectedSceneNumber = 0;
    recording.expectedNumberOfFrames = 2;
    recording.expectedErrorCode = -999;
    recording.expectedErrorDomain = NSURLErrorDomain;
    recording.expectedErrorUserInfo = @{
                                        NSURLErrorFailingURLErrorKey: [NSURL URLWithString:recording.URLString],
                                        NSURLErrorFailingURLStringErrorKey: recording.URLString,
                                        NSLocalizedDescriptionKey: @"cancelled"
                                        };
    [self recordingTaskForHTTPBinWithExpectedRecording:recording taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
}

- (void)testRecordingOnePOSTRequest {
    BKRExpectedRecording *recording = [BKRExpectedRecording recording];
    recording.URLString = @"https://httpbin.org/post";
    recording.expectedNumberOfFrames = 4;
    recording.expectedSceneNumber = 0;
    recording.responseStatusCode = 200;
    recording.HTTPMethod = @"POST";
    recording.sentJSON = @{
                           @"foo": @"bar"
                           };
    [self recordingTaskForHTTPBinWithExpectedRecording:recording taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
}

- (void)testRecordingMultipleGETRequests {
    BKRExpectedRecording *firstRecording = [BKRExpectedRecording recording];
    firstRecording.URLString = @"https://httpbin.org/get?test=test";
    firstRecording.receivedJSON = @{
                                       @"test": @"test"
                                       };
    firstRecording.responseStatusCode = 200;
    firstRecording.expectedSceneNumber = 0;
    firstRecording.expectedNumberOfFrames = 4;
    
    BKRExpectedRecording *secondRecording = [BKRExpectedRecording recording];
    secondRecording.URLString = @"https://httpbin.org/get?test=test2";
    secondRecording.receivedJSON = @{
                                    @"test": @"test2"
                                    };
    secondRecording.responseStatusCode = 200;
    secondRecording.expectedSceneNumber = 1;
    secondRecording.expectedNumberOfFrames = 4;
    
    [self recordingTaskForHTTPBinWithExpectedRecording:firstRecording taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
    
    [self recordingTaskForHTTPBinWithExpectedRecording:secondRecording taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 2);
    }];
}

- (void)testRecordingTwoConsecutiveGETRequestsWithSameRequestURLAndDifferentResponses {
    BKRExpectedRecording *firstRecording = [BKRExpectedRecording recording];
    firstRecording.URLString = @"https://pubsub.pubnub.com/time/0";
    firstRecording.responseStatusCode = 200;
    firstRecording.expectedSceneNumber = 0;
    firstRecording.expectedNumberOfFrames = 4;
    
    BKRExpectedRecording *secondRecording = [BKRExpectedRecording recording];
    secondRecording.URLString = @"https://pubsub.pubnub.com/time/0";
    secondRecording.receivedJSON = @{
                                     @"test": @"test2"
                                     };
    secondRecording.responseStatusCode = 200;
    secondRecording.expectedSceneNumber = 1;
    secondRecording.expectedNumberOfFrames = 4;
    
    __block NSNumber *firstTimetoken = nil;
    [self recordingTaskWithExpectedRecording:firstRecording taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        // ensure that result from network is as expected
        XCTAssertNotNil(dataArray);
        firstTimetoken = dataArray.firstObject;
        XCTAssertNotNil(firstTimetoken);
        XCTAssertTrue([firstTimetoken isKindOfClass:[NSNumber class]]);
        NSTimeInterval firstTimeTokenAsUnix = [self unixTimestampForPubNubTimetoken:firstTimetoken];
        NSTimeInterval currentUnixTimestamp = [[NSDate date] timeIntervalSince1970];
        XCTAssertEqualWithAccuracy(firstTimeTokenAsUnix, currentUnixTimestamp, 5);
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
    
    [self recordingTaskWithExpectedRecording:secondRecording taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        // ensure that result from network is as expected
        XCTAssertNotNil(dataArray);
        NSNumber *secondTimetoken = dataArray.firstObject;
        XCTAssertNotNil(secondTimetoken);
        XCTAssertTrue([secondTimetoken isKindOfClass:[NSNumber class]]);
        NSTimeInterval secondTimeTokenAsUnix = [self unixTimestampForPubNubTimetoken:secondTimetoken];
        NSTimeInterval currentUnixTimestamp = [[NSDate date] timeIntervalSince1970];
        XCTAssertEqualWithAccuracy(secondTimeTokenAsUnix, currentUnixTimestamp, 5);
        // also make sure that the two time tokens returned are different
        XCTAssertNotEqualObjects(firstTimetoken, secondTimetoken);
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 2);
    }];
}

@end
