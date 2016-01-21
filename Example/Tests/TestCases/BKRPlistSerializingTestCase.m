//
//  BKRPlistSerializingTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/21/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <BeKindRewind/BKRRecordableCassette.h>
#import <BeKindRewind/BKRScene.h>
#import <BeKindRewind/BKRRawFrame.h>
#import <BeKindRewind/BKRDataFrame.h>
#import <BeKindRewind/BKRResponseFrame.h>
#import <BeKindRewind/BKRRequestFrame.h>
#import <BeKindRewind/NSURLSessionTask+BKRAdditions.h>
#import "XCTestCase+BKRAdditions.h"

@interface BKRPlistSerializingTestCase : XCTestCase
@property (nonatomic, strong) BKRRecordableCassette *cassette;
@end

@implementation BKRPlistSerializingTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    BKRRecordableCassette *testCassette = [[BKRRecordableCassette alloc] init];
    testCassette.recording = YES;
    self.cassette = testCassette;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.cassette = nil;
    [super tearDown];
}

- (void)testPlistSerialization {
    __weak typeof(self) wself = self;
    [self getTaskWithURLString:@"https://httpbin.org/get?test=test" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        __strong typeof(wself) sself = wself;
        [task uniqueify];
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        XCTAssertNil(error);
        // ensure that result from network is as expected
        XCTAssertEqualObjects(dataDict[@"args"], @{@"test": @"test"});
        BKRRawFrame *dataRawFrame = [BKRRawFrame frameWithTask:task];
        dataRawFrame.item = data;
        [sself.cassette addFrame:dataRawFrame];
        
        BKRRawFrame *originalRequestRawFrame = [BKRRawFrame frameWithTask:task];
        originalRequestRawFrame.item = task.originalRequest;
        [sself.cassette addFrame:originalRequestRawFrame];
        
        BKRRawFrame *currentRequestRawFrame = [BKRRawFrame frameWithTask:task];
        currentRequestRawFrame.item = task.currentRequest;
        [sself.cassette addFrame:currentRequestRawFrame];
        
        BKRRawFrame *responseRawFrame = [BKRRawFrame frameWithTask:task];
        responseRawFrame.item = response;
        [sself.cassette addFrame:responseRawFrame];
        
        XCTAssertEqual([(NSHTTPURLResponse *)response statusCode], 200);
        
        
        XCTAssertEqual(sself.cassette.allScenes.count, 1);
        BKRScene *scene = sself.cassette.allScenes.firstObject;
        XCTAssertEqual(scene.allFrames.count, 4);
        XCTAssertEqual(scene.allDataFrames.count, 1);
        XCTAssertEqual(scene.allRequestFrames.count, 2);
        XCTAssertEqual(scene.allResponseFrames.count, 1);
        
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        
    }];
}

@end
