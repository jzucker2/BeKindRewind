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
//    cassette.recording = YES;
    [BKRRecorder sharedInstance].currentCassette = cassette;
    [BKRRecorder sharedInstance].enabled = YES;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [[BKRRecorder sharedInstance] reset];
//    [BKRRecorder sharedInstance].currentCassette = nil; // this causes an assert to fire
    [super tearDown];
}

- (void)testRecordingOneGETRequest {
//    __block BKRScene *scene = nil;
//    [self getTaskWithURLString:@"https://httpbin.org/get?test=test" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//        // ensure that result from network is as expected
//        XCTAssertEqualObjects(dataDict[@"args"], @{@"test": @"test"});
//        // now current cassette in recoder should have one scene with data matching this
//        BKRCassette *cassette = [BKRRecorder sharedInstance].currentCassette;
//        XCTAssertNotNil(cassette);
//        XCTAssertEqual(cassette.allScenes.count, 1);
//        scene = cassette.allScenes.firstObject;
//        XCTAssertTrue(scene.allFrames.count > 0);
//        XCTAssertEqual(scene.allDataFrames.count, 1);
//        BKRDataFrame *dataFrame = scene.allDataFrames.firstObject;
//        [self assertData:dataFrame withData:data extraAssertions:nil];
//        XCTAssertEqual(scene.allResponseFrames.count, 1);
//        BKRResponseFrame *responseFrame = scene.allResponseFrames.firstObject;
//        XCTAssertEqual(responseFrame.statusCode, 200);
//        [self assertResponse:responseFrame withResponse:response extraAssertions:nil];
//    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
//        XCTAssertEqual(scene.allRequestFrames.count, 2);
//        NSURLRequest *originalRequest = task.originalRequest;
//        BKRRequestFrame *originalRequestFrame = scene.originalRequest;
//        XCTAssertNotNil(originalRequestFrame);
//        [self assertRequest:originalRequestFrame withRequest:originalRequest extraAssertions:nil];
//        XCTAssertNotNil(scene.currentRequest);
//        [self assertRequest:scene.currentRequest withRequest:task.currentRequest extraAssertions:nil];
//        [self assertFramesOrder:scene extraAssertions:nil];
//    }];
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
    
//    __block BKRScene *scene = nil;
//    NSDictionary *rawPostDictionary = @{@"foo": @"bar"};
//    NSData *postData = [NSJSONSerialization dataWithJSONObject:rawPostDictionary options:NSJSONWritingPrettyPrinted error:nil];
//    [self post:postData withURLString:@"https://httpbin.org/post" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        // ensure that data returned is same as data posted
//        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//        NSDictionary *formDict = dataDict[@"form"];
//        // for this service, need to fish out the data sent
//        NSArray *formKeys = formDict.allKeys;
//        NSString *rawReceivedDataString = formKeys.firstObject;
//        NSDictionary *receivedDataDictionary = [NSJSONSerialization JSONObjectWithData:[rawReceivedDataString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
//        // ensure that result from network is as expected
//        XCTAssertEqualObjects(rawPostDictionary, receivedDataDictionary);
//        // now current cassette in recoder should have one scene with data matching this
//        BKRCassette *cassette = [BKRRecorder sharedInstance].currentCassette;
//        XCTAssertNotNil(cassette);
//        XCTAssertEqual(cassette.allScenes.count, 1);
//        scene = cassette.allScenes.firstObject;
//        XCTAssertTrue(scene.allFrames.count > 0);
//        XCTAssertEqual(scene.allDataFrames.count, 1);
//        BKRDataFrame *dataFrame = scene.allDataFrames.firstObject;
//        [self assertData:dataFrame withData:data extraAssertions:nil];
//        XCTAssertEqual(scene.allResponseFrames.count, 1);
//        BKRResponseFrame *responseFrame = scene.allResponseFrames.firstObject;
//        XCTAssertEqual(responseFrame.statusCode, 200);
//        [self assertResponse:responseFrame withResponse:response extraAssertions:nil];
//    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
//        XCTAssertEqual(scene.allRequestFrames.count, 2);
//        NSURLRequest *originalRequest = task.originalRequest;
//        BKRRequestFrame *originalRequestFrame = scene.originalRequest;
//        XCTAssertNotNil(originalRequestFrame);
//        XCTAssertEqualObjects(originalRequestFrame.HTTPMethod, @"POST");
//        [self assertRequest:originalRequestFrame withRequest:originalRequest extraAssertions:nil];
//        XCTAssertNotNil(scene.currentRequest);
//        [self assertRequest:scene.currentRequest withRequest:task.currentRequest extraAssertions:nil];
//        [self assertFramesOrder:scene extraAssertions:nil];
//    }];
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
    
    
    
    
    
    
//    __block BKRScene *firstScene = nil;
//    [self getTaskWithURLString:@"https://httpbin.org/get?test=test" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//        // ensure that result from network is as expected
//        XCTAssertEqualObjects(dataDict[@"args"], @{@"test": @"test"});
//        // now current cassette in recorder should have one scene with data matching this
//        BKRCassette *cassette = [BKRRecorder sharedInstance].currentCassette;
//        XCTAssertNotNil(cassette);
//        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
//        firstScene = (BKRScene *)[BKRRecorder sharedInstance].allScenes.firstObject;
//        XCTAssertTrue(firstScene.allFrames.count > 0);
//        XCTAssertEqual(firstScene.allDataFrames.count, 1);
//        BKRDataFrame *dataFrame = firstScene.allDataFrames.firstObject;
//        [self assertData:dataFrame withData:data extraAssertions:nil];
//        XCTAssertEqual(firstScene.allResponseFrames.count, 1);
//        BKRResponseFrame *responseFrame = firstScene.allResponseFrames.firstObject;
//        XCTAssertEqual(responseFrame.statusCode, 200);
//        [self assertResponse:responseFrame withResponse:response extraAssertions:nil];
//    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
//        XCTAssertEqual(firstScene.allRequestFrames.count, 2);
//        NSURLRequest *originalRequest = task.originalRequest;
//        BKRRequestFrame *originalRequestFrame = firstScene.originalRequest;
//        XCTAssertNotNil(originalRequestFrame);
//        [self assertRequest:originalRequestFrame withRequest:originalRequest extraAssertions:nil];
//        XCTAssertNotNil(firstScene.currentRequest);
//        [self assertRequest:firstScene.currentRequest withRequest:task.currentRequest extraAssertions:nil];
//        [self assertFramesOrder:firstScene extraAssertions:nil];
//    }];
//    
//    __block BKRScene *secondScene = nil;
//    [self getTaskWithURLString:@"https://httpbin.org/get?test=test2" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//        // ensure that result from network is as expected
//        XCTAssertEqualObjects(dataDict[@"args"], @{@"test": @"test2"});
//        // now current cassette in recorder should have one scene with data matching this
//        BKRCassette *cassette = [BKRRecorder sharedInstance].currentCassette;
//        XCTAssertNotNil(cassette);
//        XCTAssertEqual(cassette.allScenes.count, 2);
//        secondScene = cassette.allScenes.lastObject;
//        XCTAssertNotEqualObjects(firstScene.uniqueIdentifier, secondScene.uniqueIdentifier, @"The two scenes should not be identical");
//        XCTAssertTrue(secondScene.allFrames.count > 0);
//        XCTAssertEqual(secondScene.allDataFrames.count, 1);
//        BKRDataFrame *dataFrame = secondScene.allDataFrames.firstObject;
//        [self assertData:dataFrame withData:data extraAssertions:nil];
//        XCTAssertEqual(secondScene.allResponseFrames.count, 1);
//        BKRResponseFrame *responseFrame = secondScene.allResponseFrames.firstObject;
//        XCTAssertEqual(responseFrame.statusCode, 200);
//        [self assertResponse:responseFrame withResponse:response extraAssertions:nil];
//    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
//        XCTAssertEqual(secondScene.allRequestFrames.count, 2);
//        XCTAssertEqual([firstScene.clapboardFrame.creationDate compare:secondScene.clapboardFrame.creationDate], NSOrderedAscending);
//        NSURLRequest *originalRequest = task.originalRequest;
//        BKRRequestFrame *originalRequestFrame = secondScene.originalRequest;
//        XCTAssertNotNil(originalRequestFrame);
//        [self assertRequest:originalRequestFrame withRequest:originalRequest extraAssertions:nil];
//        XCTAssertNotNil(secondScene.currentRequest);
//        [self assertRequest:secondScene.currentRequest withRequest:task.currentRequest extraAssertions:nil];
//        [self assertFramesOrder:secondScene extraAssertions:nil];
//    }];
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
    
    
    
    
    
//    NSString *URLString = @"https://pubsub.pubnub.com/time/0";
//    __block BKRScene *firstScene = nil;
//    __block NSNumber *firstTimetoken = nil;
//    [self getTaskWithURLString:URLString taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//        // ensure that result from network is as expected
//        XCTAssertNotNil(dataArray);
//        firstTimetoken = dataArray.firstObject;
//        XCTAssertNotNil(firstTimetoken);
//        XCTAssertTrue([firstTimetoken isKindOfClass:[NSNumber class]]);
//        NSTimeInterval firstTimeTokenAsUnix = [self unixTimestampForPubNubTimetoken:firstTimetoken];
//        NSTimeInterval currentUnixTimestamp = [[NSDate date] timeIntervalSince1970];
//        XCTAssertEqualWithAccuracy(firstTimeTokenAsUnix, currentUnixTimestamp, 5);
//        // now current cassette in recorder should have one scene with data matching this
//        BKRCassette *cassette = [BKRRecorder sharedInstance].currentCassette;
//        XCTAssertNotNil(cassette);
//        XCTAssertEqual(cassette.allScenes.count, 1);
//        firstScene = cassette.allScenes.firstObject;
//        XCTAssertTrue(firstScene.allFrames.count > 0);
//        XCTAssertEqual(firstScene.allDataFrames.count, 1);
//        BKRDataFrame *dataFrame = firstScene.allDataFrames.firstObject;
//        [self assertData:dataFrame withData:data extraAssertions:nil];
//        XCTAssertEqual(firstScene.allResponseFrames.count, 1);
//        BKRResponseFrame *responseFrame = firstScene.allResponseFrames.firstObject;
//        XCTAssertEqual(responseFrame.statusCode, 200);
//        [self assertResponse:responseFrame withResponse:response extraAssertions:nil];
//    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
//        XCTAssertEqual(firstScene.allRequestFrames.count, 2);
//        NSURLRequest *originalRequest = task.originalRequest;
//        BKRRequestFrame *originalRequestFrame = firstScene.originalRequest;
//        XCTAssertNotNil(originalRequestFrame);
//        [self assertRequest:originalRequestFrame withRequest:originalRequest extraAssertions:nil];
//        XCTAssertNotNil(firstScene.currentRequest);
//        [self assertRequest:firstScene.currentRequest withRequest:task.currentRequest extraAssertions:nil];
//        [self assertFramesOrder:firstScene extraAssertions:nil];
//    }];
//    
//    __block BKRScene *secondScene = nil;
//    [self getTaskWithURLString:URLString taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
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
//        // now current cassette in recorder should have one scene with data matching this
//        BKRCassette *cassette = [BKRRecorder sharedInstance].currentCassette;
//        XCTAssertNotNil(cassette);
//        XCTAssertEqual(cassette.allScenes.count, 2);
//        secondScene = cassette.allScenes.lastObject;
//        XCTAssertNotEqualObjects(firstScene.uniqueIdentifier, secondScene.uniqueIdentifier, @"The two scenes should not be identical");
//        XCTAssertTrue(secondScene.allFrames.count > 0);
//        XCTAssertEqual(secondScene.allDataFrames.count, 1);
//        BKRDataFrame *dataFrame = secondScene.allDataFrames.firstObject;
//        [self assertData:dataFrame withData:data extraAssertions:nil];
//        XCTAssertEqual(secondScene.allResponseFrames.count, 1);
//        BKRResponseFrame *responseFrame = secondScene.allResponseFrames.firstObject;
//        XCTAssertEqual(responseFrame.statusCode, 200);
//        [self assertResponse:responseFrame withResponse:response extraAssertions:nil];
//    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
//        XCTAssertEqual(secondScene.allRequestFrames.count, 2);
//        XCTAssertEqual([firstScene.clapboardFrame.creationDate compare:secondScene.clapboardFrame.creationDate], NSOrderedAscending);
//        NSURLRequest *originalRequest = task.originalRequest;
//        BKRRequestFrame *originalRequestFrame = secondScene.originalRequest;
//        XCTAssertNotNil(originalRequestFrame);
//        [self assertRequest:originalRequestFrame withRequest:originalRequest extraAssertions:nil];
//        XCTAssertNotNil(secondScene.currentRequest);
//        [self assertRequest:secondScene.currentRequest withRequest:task.currentRequest extraAssertions:nil];
//        [self assertFramesOrder:secondScene extraAssertions:nil];
//    }];
}

@end
