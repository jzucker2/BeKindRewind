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

- (void)testBasicRecordingForGETRequest {
    __block BKRScene *scene = nil;
    [self getTaskWithURLString:@"https://httpbin.org/get?test=test" taskCompletionAssertions:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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
    } taskTimeoutAssertions:^(NSURLSessionTask * _Nullable task, NSError * _Nullable error) {
        XCTAssertEqual(scene.allRequestFrames.count, 2);
        NSURLRequest *originalRequest = task.originalRequest;
        XCTAssertNotNil(originalRequest);
        BKRRequestFrame *originalRequestFrame = scene.originalRequest;
        XCTAssertNotNil(originalRequestFrame);
        [self assertRequest:originalRequestFrame withRequest:originalRequest extraAssertions:nil];
        [self assertRequest:scene.currentRequest withRequest:task.currentRequest extraAssertions:nil];
    }];
}

- (void)testRecordingTwoGETRequests {
    NSDictionary *dictionary = nil;
    NSMutableDictionary *secondDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    XCTAssertNotNil(secondDictionary);
    secondDictionary[@"test"] = @2;
    XCTAssertEqualObjects(secondDictionary[@"test"], @2);
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
