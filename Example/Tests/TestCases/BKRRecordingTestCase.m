//
//  BKRRecordingTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/19/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <BeKindRewind/BKRRecorder.h>
#import <BeKindRewind/BKRCassette.h>
#import <BeKindRewind/BKRScene.h>
#import <BeKindRewind/BKRDataFrame.h>
#import <BeKindRewind/BKRResponse.h>
#import <BeKindRewind/BKRRequest.h>
#import <BeKindRewind/BKRNSURLSessionConnection.h>

@interface BKRRecordingTestCase : XCTestCase
@end

@implementation BKRRecordingTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [BKRNSURLSessionConnection swizzleNSURLSessionClasses];
    BKRCassette *cassette = [[BKRCassette alloc] init];
    cassette.recording = YES;
    [BKRRecorder sharedInstance].currentCassette = cassette;
    [BKRRecorder sharedInstance].enabled = YES;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [[BKRRecorder sharedInstance] reset];
    [BKRRecorder sharedInstance].currentCassette = nil;
    [super tearDown];
}

- (void)testBasicRecordingForGETRequest {
    __block XCTestExpectation *basicGetExpectation = [self expectationWithDescription:@"basicGetExpectation"];
    __block BKRScene *scene = nil;
    NSURL *basicGetURL = [NSURL URLWithString:@"https://httpbin.org/get?test=test"];
    NSURLRequest *basicGetRequest = [NSURLRequest requestWithURL:basicGetURL];
    NSURLSessionDataTask *basicGetTask = [[NSURLSession sharedSession] dataTaskWithRequest:basicGetRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNotNil(data);
        XCTAssertNil(error);
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
        NSDictionary *recordedDataObject = dataFrame.JSONConvertedObject;
        XCTAssertEqualObjects(dataDict[@"args"], recordedDataObject[@"args"]);
        XCTAssertNotNil(response);
        XCTAssertEqual(scene.allResponseFrames.count, 1);
        BKRResponse *responseFrame = scene.allResponseFrames.firstObject;
        XCTAssertEqual(responseFrame.statusCode, 200);
        NSHTTPURLResponse *castedDataTaskResponse = (NSHTTPURLResponse *)response;
        XCTAssertEqualObjects(responseFrame.allHeaderFields, castedDataTaskResponse.allHeaderFields);
        XCTAssertEqual(responseFrame.statusCode, castedDataTaskResponse.statusCode);
        [basicGetExpectation fulfill];
    }];
    XCTAssertEqual(basicGetTask.state, NSURLSessionTaskStateSuspended);
    [basicGetTask resume];
    XCTAssertEqual(basicGetTask.state, NSURLSessionTaskStateRunning);
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertEqual(basicGetTask.state, NSURLSessionTaskStateCompleted);
        XCTAssertEqual(scene.allRequestFrames.count, 2);
        NSURLRequest *originalRequest = basicGetTask.originalRequest;
        XCTAssertNotNil(originalRequest);
        BKRRequest *originalRequestFrame = scene.originalRequest;
        XCTAssertNotNil(originalRequestFrame);
        XCTAssertTrue(originalRequestFrame.isOriginalRequest);
        XCTAssertEqual(originalRequestFrame.HTTPShouldHandleCookies, originalRequest.HTTPShouldHandleCookies);
        XCTAssertEqual(originalRequestFrame.HTTPShouldUsePipelining, originalRequest.HTTPShouldUsePipelining);
        XCTAssertEqualObjects(originalRequestFrame.allHTTPHeaderFields, originalRequest.allHTTPHeaderFields);
        XCTAssertEqualObjects(originalRequestFrame.URL, originalRequest.URL);
        XCTAssertEqual(originalRequestFrame.timeoutInterval, originalRequest.timeoutInterval);
        XCTAssertEqualObjects(originalRequestFrame.HTTPMethod, originalRequest.HTTPMethod);
        XCTAssertEqual(originalRequestFrame.allowsCellularAccess, originalRequest.allowsCellularAccess);
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
