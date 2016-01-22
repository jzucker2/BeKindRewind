//
//  BKRRecordingTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/19/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <BeKindRewind/BKRRecorder.h>
#import <BeKindRewind/BKRRecordableCassette.h>
#import <BeKindRewind/BKRScene.h>
#import <BeKindRewind/BKRDataFrame.h>
#import <BeKindRewind/BKRResponseFrame.h>
#import <BeKindRewind/BKRRequestFrame.h>
#import <BeKindRewind/BKRNSURLSessionConnection.h>
#import "XCTestCase+BKRAdditions.h"

@interface BKRRecordingTestCase : XCTestCase
@end

@implementation BKRRecordingTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [BKRNSURLSessionConnection swizzleNSURLSessionClasses];
    BKRRecordableCassette *cassette = [[BKRRecordableCassette alloc] init];
    cassette.recording = YES;
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
    __block BKRScene *scene = nil;
    [self getTaskWithURLString:@"https://httpbin.org/get?test=test" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        XCTAssertNil(error);
        // ensure that result from network is as expected
        XCTAssertEqualObjects(dataDict[@"args"], @{@"test": @"test"});
        // now current cassette in recoder should have one scene with data matching this
        BKRCassette *cassette = [BKRRecorder sharedInstance].currentCassette;
        XCTAssertNotNil(cassette);
        XCTAssertEqual(cassette.allScenes.count, 1);
        scene = cassette.allScenes.firstObject;
        XCTAssertTrue(scene.allFrames.count > 0);
        XCTAssertEqual(scene.allDataFrames.count, 1);
        BKRDataFrame *dataFrame = scene.allDataFrames.firstObject;
        [self assertData:dataFrame withData:data extraAssertions:nil];
        XCTAssertEqual(scene.allResponseFrames.count, 1);
        BKRResponseFrame *responseFrame = scene.allResponseFrames.firstObject;
        XCTAssertEqual(responseFrame.statusCode, 200);
        [self assertResponse:responseFrame withResponse:response extraAssertions:nil];
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual(scene.allRequestFrames.count, 2);
        NSURLRequest *originalRequest = task.originalRequest;
        BKRRequestFrame *originalRequestFrame = scene.originalRequest;
        XCTAssertNotNil(originalRequestFrame);
        [self assertRequest:originalRequestFrame withRequest:originalRequest extraAssertions:nil];
        XCTAssertNotNil(scene.currentRequest);
        [self assertRequest:scene.currentRequest withRequest:task.currentRequest extraAssertions:nil];
        [self assertFramesOrder:scene extraAssertions:nil];
    }];
}

- (void)testRecordingOnePOSTRequest {
    __block BKRScene *scene = nil;
    NSDictionary *rawPostDictionary = @{@"foo": @"bar"};
    NSData *postData = [NSJSONSerialization dataWithJSONObject:rawPostDictionary options:NSJSONWritingPrettyPrinted error:nil];
    [self post:postData withURLString:@"https://httpbin.org/post" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertNil(error);
        // ensure that data returned is same as data posted
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSDictionary *formDict = dataDict[@"form"];
        // for this service, need to fish out the data sent
        NSArray *formKeys = formDict.allKeys;
        NSString *rawReceivedDataString = formKeys.firstObject;
        NSDictionary *receivedDataDictionary = [NSJSONSerialization JSONObjectWithData:[rawReceivedDataString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        // ensure that result from network is as expected
        XCTAssertEqualObjects(rawPostDictionary, receivedDataDictionary);
        // now current cassette in recoder should have one scene with data matching this
        BKRCassette *cassette = [BKRRecorder sharedInstance].currentCassette;
        XCTAssertNotNil(cassette);
        XCTAssertEqual(cassette.allScenes.count, 1);
        scene = cassette.allScenes.firstObject;
        XCTAssertTrue(scene.allFrames.count > 0);
        XCTAssertEqual(scene.allDataFrames.count, 1);
        BKRDataFrame *dataFrame = scene.allDataFrames.firstObject;
        [self assertData:dataFrame withData:data extraAssertions:nil];
        XCTAssertEqual(scene.allResponseFrames.count, 1);
        BKRResponseFrame *responseFrame = scene.allResponseFrames.firstObject;
        XCTAssertEqual(responseFrame.statusCode, 200);
        [self assertResponse:responseFrame withResponse:response extraAssertions:nil];
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual(scene.allRequestFrames.count, 2);
        NSURLRequest *originalRequest = task.originalRequest;
        BKRRequestFrame *originalRequestFrame = scene.originalRequest;
        XCTAssertNotNil(originalRequestFrame);
        XCTAssertEqualObjects(originalRequestFrame.HTTPMethod, @"POST");
        [self assertRequest:originalRequestFrame withRequest:originalRequest extraAssertions:nil];
        XCTAssertNotNil(scene.currentRequest);
        [self assertRequest:scene.currentRequest withRequest:task.currentRequest extraAssertions:nil];
        [self assertFramesOrder:scene extraAssertions:nil];
    }];
}



- (void)testRecordingMultipleGETRequests {
    __block BKRScene *firstScene = nil;
    [self getTaskWithURLString:@"https://httpbin.org/get?test=test" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        XCTAssertNil(error);
        // ensure that result from network is as expected
        XCTAssertEqualObjects(dataDict[@"args"], @{@"test": @"test"});
        // now current cassette in recoder should have one scene with data matching this
        BKRCassette *cassette = [BKRRecorder sharedInstance].currentCassette;
        XCTAssertNotNil(cassette);
        XCTAssertEqual(cassette.allScenes.count, 1);
        firstScene = cassette.allScenes.firstObject;
        XCTAssertTrue(firstScene.allFrames.count > 0);
        XCTAssertEqual(firstScene.allDataFrames.count, 1);
        BKRDataFrame *dataFrame = firstScene.allDataFrames.firstObject;
        [self assertData:dataFrame withData:data extraAssertions:nil];
        XCTAssertEqual(firstScene.allResponseFrames.count, 1);
        BKRResponseFrame *responseFrame = firstScene.allResponseFrames.firstObject;
        XCTAssertEqual(responseFrame.statusCode, 200);
        [self assertResponse:responseFrame withResponse:response extraAssertions:nil];
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual(firstScene.allRequestFrames.count, 2);
        NSURLRequest *originalRequest = task.originalRequest;
        BKRRequestFrame *originalRequestFrame = firstScene.originalRequest;
        XCTAssertNotNil(originalRequestFrame);
        [self assertRequest:originalRequestFrame withRequest:originalRequest extraAssertions:nil];
        XCTAssertNotNil(firstScene.currentRequest);
        [self assertRequest:firstScene.currentRequest withRequest:task.currentRequest extraAssertions:nil];
        [self assertFramesOrder:firstScene extraAssertions:nil];
    }];
    
    __block BKRScene *secondScene = nil;
    [self getTaskWithURLString:@"https://httpbin.org/get?test=test2" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        XCTAssertNil(error);
        // ensure that result from network is as expected
        XCTAssertEqualObjects(dataDict[@"args"], @{@"test": @"test2"});
        // now current cassette in recoder should have one scene with data matching this
        BKRCassette *cassette = [BKRRecorder sharedInstance].currentCassette;
        XCTAssertNotNil(cassette);
        XCTAssertEqual(cassette.allScenes.count, 2);
        secondScene = cassette.allScenes.lastObject;
        XCTAssertNotEqualObjects(firstScene.uniqueIdentifier, secondScene.uniqueIdentifier, @"The two scenes should not be identical");
        XCTAssertTrue(secondScene.allFrames.count > 0);
        XCTAssertEqual(secondScene.allDataFrames.count, 1);
        BKRDataFrame *dataFrame = secondScene.allDataFrames.firstObject;
        [self assertData:dataFrame withData:data extraAssertions:nil];
        XCTAssertEqual(secondScene.allResponseFrames.count, 1);
        BKRResponseFrame *responseFrame = secondScene.allResponseFrames.firstObject;
        XCTAssertEqual(responseFrame.statusCode, 200);
        [self assertResponse:responseFrame withResponse:response extraAssertions:nil];
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual(secondScene.allRequestFrames.count, 2);
        XCTAssertEqual([firstScene.clapboardFrame.creationDate compare:secondScene.clapboardFrame.creationDate], NSOrderedAscending);
        NSURLRequest *originalRequest = task.originalRequest;
        BKRRequestFrame *originalRequestFrame = secondScene.originalRequest;
        XCTAssertNotNil(originalRequestFrame);
        [self assertRequest:originalRequestFrame withRequest:originalRequest extraAssertions:nil];
        XCTAssertNotNil(secondScene.currentRequest);
        [self assertRequest:secondScene.currentRequest withRequest:task.currentRequest extraAssertions:nil];
        [self assertFramesOrder:secondScene extraAssertions:nil];
    }];
}

@end
