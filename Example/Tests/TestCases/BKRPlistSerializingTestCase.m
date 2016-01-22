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
        [self addTask:task data:data response:response error:error toCassette:sself.cassette];
        
        XCTAssertEqualObjects(dataDict[@"args"], @{@"test": @"test"});
        XCTAssertEqual([(NSHTTPURLResponse *)response statusCode], 200);
        
        // Keep this assert here, it tests to make sure that count happens after raw frames are processed
        XCTAssertEqual(sself.cassette.allScenes.count, 1);
        BKRScene *scene = sself.cassette.allScenes.firstObject;
        XCTAssertEqual(scene.allFrames.count, 4);
        XCTAssertEqual(scene.allDataFrames.count, 1);
        XCTAssertEqual(scene.allRequestFrames.count, 2);
        XCTAssertEqual(scene.allResponseFrames.count, 1);
        [self assertFramesOrder:scene extraAssertions:nil];
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        __strong typeof(wself) sself = wself;
        XCTAssertEqual(sself.cassette.allScenes.count, 1, @"How did the count of scenes change?");
        BKRScene *recordedScene = sself.cassette.allScenes.firstObject;
        NSDictionary *cassetteDict = sself.cassette.plistDictionary;
        XCTAssertNotNil(cassetteDict);
        XCTAssertNotNil(cassetteDict[@"scenes"]);
        XCTAssertNotNil(cassetteDict[@"creationDate"]);
        XCTAssertTrue([cassetteDict[@"creationDate"] isKindOfClass:[NSDate class]]);
        NSArray *scenes = cassetteDict[@"scenes"];
        XCTAssertEqual(scenes.count, 1);
        NSDictionary *sceneDict = scenes.firstObject;
        NSArray *frames = sceneDict[@"frames"];
        XCTAssertEqual(recordedScene.allFrames.count, frames.count);
        XCTAssertEqualObjects(task.globallyUniqueIdentifier, sceneDict[@"uniqueIdentifier"]);
        [self assertFramesOrder:recordedScene extraAssertions:nil];
        for (NSInteger i = 0; i < frames.count; i++) {
            BKRFrame *frame = [recordedScene.allFrames objectAtIndex:i];
            NSDictionary *frameDict = [frames objectAtIndex:i];
            XCTAssertEqual(frame.creationDate, frameDict[@"creationDate"]);
            XCTAssertEqualObjects(sceneDict[@"uniqueIdentifier"], frameDict[@"uniqueIdentifier"]);
            if ([frame isKindOfClass:[BKRDataFrame class]]) {
                [self assertData:(BKRDataFrame *)frame withDataDict:frameDict extraAssertions:nil];
            } else if ([frame isKindOfClass:[BKRResponseFrame class]]) {
                [self assertResponse:(BKRResponseFrame *)frame withResponseDict:frameDict extraAssertions:nil];
            } else if ([frame isKindOfClass:[BKRRequestFrame class]]) {
                [self assertRequest:(BKRRequestFrame *)frame withRequestDict:frameDict extraAssertions:nil];
            } else {
                XCTFail(@"encountered unknown frame type: %@", frame);
            }
        }
    }];
}

- (void)testPlistDeserialization {
    __weak typeof(self) wself = self;
    [self getTaskWithURLString:@"https://httpbin.org/get?test=test" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        __strong typeof(wself) sself = wself;
        [task uniqueify];
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        XCTAssertNil(error);
        // ensure that result from network is as expected
        [self addTask:task data:data response:response error:error toCassette:sself.cassette];
        
        XCTAssertEqualObjects(dataDict[@"args"], @{@"test": @"test"});
        XCTAssertEqual([(NSHTTPURLResponse *)response statusCode], 200);
        
        // Keep this assert here, it tests to make sure that count happens after raw frames are processed
        XCTAssertEqual(sself.cassette.allScenes.count, 1);
        BKRScene *scene = sself.cassette.allScenes.firstObject;
        XCTAssertEqual(scene.allFrames.count, 4);
        XCTAssertEqual(scene.allDataFrames.count, 1);
        XCTAssertEqual(scene.allRequestFrames.count, 2);
        XCTAssertEqual(scene.allResponseFrames.count, 1);
        [self assertFramesOrder:scene extraAssertions:nil];
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        __strong typeof(wself) sself = wself;
        XCTAssertEqual(sself.cassette.allScenes.count, 1, @"How did the count of scenes change?");
        NSArray *framesArray = @[
                                 
                                 
                                 ];
        NSDictionary *sceneDict = @{
                                    @"uniqueIdentifier": task.globallyUniqueIdentifier,
                                    @"frames": framesArray
                                    };
        NSArray *scenesArray = @[
                                 sceneDict
                                 ];
        NSDictionary *cassetteDict = @{
                                       @"uniqueIdentifier": task.globallyUniqueIdentifier,
                                       @"scenes": scenesArray
                                       };
        XCTAssertNotNil(cassetteDict);
//        BKRScene *recordedScene = sself.cassette.allScenes.firstObject;
//        NSDictionary *cassetteDict = sself.cassette.plistDictionary;
//        XCTAssertNotNil(cassetteDict);
//        XCTAssertNotNil(cassetteDict[@"scenes"]);
//        XCTAssertNotNil(cassetteDict[@"creationDate"]);
//        XCTAssertTrue([cassetteDict[@"creationDate"] isKindOfClass:[NSDate class]]);
//        NSArray *scenes = cassetteDict[@"scenes"];
//        XCTAssertEqual(scenes.count, 1);
//        NSDictionary *sceneDict = scenes.firstObject;
//        NSArray *frames = sceneDict[@"frames"];
//        XCTAssertEqual(recordedScene.allFrames.count, frames.count);
//        XCTAssertEqualObjects(task.globallyUniqueIdentifier, sceneDict[@"uniqueIdentifier"]);
//        [self assertFramesOrder:recordedScene extraAssertions:nil];
//        for (NSInteger i = 0; i < frames.count; i++) {
//            BKRFrame *frame = [recordedScene.allFrames objectAtIndex:i];
//            NSDictionary *frameDict = [frames objectAtIndex:i];
//            XCTAssertEqual(frame.creationDate, frameDict[@"creationDate"]);
//            XCTAssertEqualObjects(sceneDict[@"uniqueIdentifier"], frameDict[@"uniqueIdentifier"]);
//            if ([frame isKindOfClass:[BKRDataFrame class]]) {
//                [self assertData:(BKRDataFrame *)frame withDataDict:frameDict extraAssertions:nil];
//            } else if ([frame isKindOfClass:[BKRResponseFrame class]]) {
//                [self assertResponse:(BKRResponseFrame *)frame withResponseDict:frameDict extraAssertions:nil];
//            } else if ([frame isKindOfClass:[BKRRequestFrame class]]) {
//                [self assertRequest:(BKRRequestFrame *)frame withRequestDict:frameDict extraAssertions:nil];
//            } else {
//                XCTFail(@"encountered unknown frame type: %@", frame);
//            }
//        }
    }];
}

@end
