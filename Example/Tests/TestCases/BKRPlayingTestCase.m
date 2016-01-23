//
//  BKRPlayingTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/22/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <BeKindRewind/BKRPlayer.h>
#import <BeKindRewind/BKRPlayableCassette.h>
#import <BeKindRewind/BKRScene.h>
#import <BeKindRewind/BKRDataFrame.h>
#import <BeKindRewind/BKRResponseFrame.h>
#import <BeKindRewind/BKRRequestFrame.h>
#import <BeKindRewind/BKRNSURLSessionConnection.h>
#import "XCTestCase+BKRAdditions.h"

@interface BKRPlayingTestCase : XCTestCase

@end

@implementation BKRPlayingTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPlayingOneGETRequest {
    __block NSMutableDictionary *expectedCassetteDict = [@{
                                                           @"creationDate": [NSDate date]
                                                           } mutableCopy];
    NSString *taskUniqueIdentifier = [NSUUID UUID].UUIDString;
    
    NSMutableDictionary *expectedOriginalRequestDict = [self standardRequestDictionary];
    expectedOriginalRequestDict[@"URL"] = @"https://httpbin.org/get?test=test";
    expectedOriginalRequestDict[@"uniqueIdentifier"] = taskUniqueIdentifier;
    
    NSMutableDictionary *expectedCurrentRequestDict = [self standardRequestDictionary];
    expectedCurrentRequestDict[@"URL"] = @"https://httpbin.org/get?test=test";
    expectedCurrentRequestDict[@"uniqueIdentifier"] = taskUniqueIdentifier;
    expectedCurrentRequestDict[@"allHTTPHeaderFields"] = @{
                                                           @"Accept": @"*/*",
                                                           @"Accept-Encoding": @"gzip, deflate",
                                                           @"Accept-Language": @"en-us"
                                                           };
    
    NSMutableDictionary *expectedResponseDict = [self standardResponseDictionary];
    expectedResponseDict[@"URL"] = @"https://httpbin.org/get?test=test";
    expectedResponseDict[@"uniqueIdentifier"] = taskUniqueIdentifier;
    // from actual response
    expectedResponseDict[@"allHeaderFields"] = @{
                                                 @"Access-Control-Allow-Origin": @"*",
                                                 @"Content-Length": @"338",
                                                 @"Content-Type": @"application/json",
                                                 @"Date": @"Fri, 22 Jan 2016 20:36:26 GMT",
                                                 @"Server": @"nginx",
                                                 @"access-control-alllow-credentials": @"true"
                                                 };
    
    NSMutableDictionary *expectedDataDict = [self standardDataDictionary];
    expectedDataDict[@"uniqueIdentifier"] = taskUniqueIdentifier;
    NSDictionary *expectedData = @{
                                   @"args": @{
                                           @"test": @"test"
                                           },
                                   @"headers": @{
                                           @"Accept": @"*/*",
                                           @"Accept-Encoding": @"gzip, deflate",
                                           @"Accept-Language": @"en-us",
                                           @"Host": @"httpbin.org",
                                           @"User-Agent": @"xctest (unknown version) CFNetwork/758.2.8 Darwin/15.3.0"
                                           },
                                   @"origin": @"198.0.209.238",
                                   @"url": @"https://httpbin.org/get?test=test"
                                   };
    expectedDataDict[@"data"] = [NSJSONSerialization dataWithJSONObject:expectedData options:kNilOptions error:nil];
    
    NSArray *framesArray = @[
                             expectedOriginalRequestDict,
                             expectedCurrentRequestDict,
                             expectedResponseDict,
                             expectedDataDict
                             ];
    NSDictionary *sceneDict = @{
                                @"uniqueIdentifier": taskUniqueIdentifier,
                                @"frames": framesArray
                                };
    expectedCassetteDict[@"scenes"] = @[
                                        sceneDict
                                        ];
    __block BKRScene *scene = nil;
    BKRPlayableCassette *cassette = [[BKRPlayableCassette alloc] initFromPlistDictionary:expectedCassetteDict];
    BKRPlayer *player = [[BKRPlayer alloc] init];
    player.currentCassette = cassette;
    player.enabled = YES;
    [self getTaskWithURLString:@"https://httpbin.org/get?test=test" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        XCTAssertNil(error);
        // ensure that result from network is as expected
        XCTAssertEqualObjects(dataDict[@"args"], @{@"test": @"test"});
        // now current cassette in recoder should have one scene with data matching this
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

@end
