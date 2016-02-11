//
//  BKRPlistSerializingTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/21/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRRecordableCassette.h>
#import <BeKindRewind/BKRPlayableCassette.h>
#import <BeKindRewind/BKRScene.h>
#import <BeKindRewind/BKRRecordableRawFrame.h>
#import <BeKindRewind/BKRDataFrame.h>
#import <BeKindRewind/BKRResponseFrame.h>
#import <BeKindRewind/BKRRequestFrame.h>
#import <BeKindRewind/NSURLSessionTask+BKRAdditions.h>
#import <BeKindRewind/BKRRecordingEditor.h>
#import <BeKindRewind/BKRPlayingEditor.h>
#import "XCTestCase+BKRAdditions.h"
#import "BKRBaseTestCase.h"

// These tests could use some refactoring and love
@interface BKRPlistSerializingTestCase : BKRBaseTestCase
@end

@implementation BKRPlistSerializingTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)DISABLE_testPlistSerializingOneGETRequest {
    __block BKRRecordingEditor *editor = [BKRRecordingEditor editor];
    BKRRecordableCassette *testCassette = [[BKRRecordableCassette alloc] init];
    editor.currentCassette = testCassette;
    editor.enabled = YES;
    __block NSDictionary *taskDict;
    __block NSURLResponse *taskResponse;
    __block NSError *taskError;
    [self getTaskWithURLString:@"https://httpbin.org/get?test=test" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        [task uniqueify];
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        XCTAssertNil(error);
        // ensure that result from network is as expected
        [self addTask:task data:data response:response error:error toRecordingEditor:editor];
        
        XCTAssertEqualObjects(dataDict[@"args"], @{@"test": @"test"});
        XCTAssertEqual([(NSHTTPURLResponse *)response statusCode], 200);
        taskDict = dataDict;
        taskResponse = response;
        taskError = error;
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        // Assert later, we are testing the plist serializing, not the timing, other classes handle timing
        XCTAssertEqual(editor.allScenes.count, 1);
        BKRScene *scene = editor.allScenes.firstObject;
        XCTAssertEqual(scene.allFrames.count, 4);
        XCTAssertEqual(scene.allDataFrames.count, 1);
        XCTAssertEqual(scene.allRequestFrames.count, 2);
        XCTAssertEqual(scene.allResponseFrames.count, 1);
        XCTAssertEqual(editor.allScenes.count, 1, @"How did the count of scenes change?");
        BKRScene *recordedScene = editor.allScenes.firstObject;
        BKRRecordableCassette *cassette = (BKRRecordableCassette *)editor.currentCassette;
        XCTAssertNotNil(cassette);
        NSDictionary *cassetteDict = cassette.plistDictionary;
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

- (void)DISABLE_testPlistDeserializingOneGETRequest {
    NSString *taskUniqueIdentifier = [NSUUID UUID].UUIDString;
    NSDate *cassetteCreationDate = [NSDate date];
    [self getTaskWithURLString:@"https://httpbin.org/get?test=test" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        task.globallyUniqueIdentifier = taskUniqueIdentifier;
        XCTAssertNil(error);
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        XCTAssertEqualObjects(dataDict[@"args"], @{@"test": @"test"});
        XCTAssertEqual([(NSHTTPURLResponse *)response statusCode], 200);
        NSDictionary *originalRequestFrameDict = [self dictionaryWithRequest:task.originalRequest forTask:task];
        NSDictionary *currentRequestFrameDict = [self dictionaryWithRequest:task.currentRequest forTask:task];
        NSDictionary *responseFrameDict = [self dictionaryWithResponse:response forTask:task];
        NSDictionary *dataFrameDict = [self dictionaryWithData:data forTask:task];
        NSArray *frames = @[
                            originalRequestFrameDict,
                            currentRequestFrameDict,
                            responseFrameDict,
                            dataFrameDict
                            ];
        NSDictionary *sceneDict = @{
                                    @"uniqueIdentifier": task.globallyUniqueIdentifier,
                                    @"frames": frames
                                    };
        NSDictionary *cassetteDict = [self expectedCassetteDictionaryWithCreationDate:cassetteCreationDate sceneDictionaries:@[sceneDict]];
        BKRPlayableCassette *cassette = [[BKRPlayableCassette alloc] initFromPlistDictionary:cassetteDict];
        XCTAssertNotNil(cassette);
        XCTAssertEqual(cassette.allScenes.count, 1);
        XCTAssertEqualObjects(cassette.creationDate, cassetteCreationDate);
        BKRScene *scene = cassette.allScenes.firstObject;
        [self assertFramesOrder:scene extraAssertions:nil];
        BOOL firstRequest = YES;
        for (NSInteger i= 0; i < scene.allFrames.count; i++) {
            BKRFrame *frame = [scene.allFrames objectAtIndex:i];
            NSDictionary *frameDict = [frames objectAtIndex:i];
            XCTAssertEqual(frame.creationDate, frameDict[@"creationDate"]);
            XCTAssertEqualObjects(sceneDict[@"uniqueIdentifier"], frameDict[@"uniqueIdentifier"]);
            if ([frame isKindOfClass:[BKRDataFrame class]]) {
                [self assertData:(BKRDataFrame *)frame withData:data extraAssertions:nil];
            } else if ([frame isKindOfClass:[BKRResponseFrame class]]) {
                [self assertResponse:(BKRResponseFrame *)frame withResponse:response extraAssertions:nil];
            } else if ([frame isKindOfClass:[BKRRequestFrame class]]) {
                NSURLRequest *matcherRequest;
                if (firstRequest) {
                    matcherRequest = task.originalRequest;
                    firstRequest = NO;
                } else {
                    matcherRequest = task.currentRequest;
                }
                [self assertRequest:(BKRRequestFrame *)frame withRequest:matcherRequest extraAssertions:nil];
            } else {
                XCTFail(@"encountered unknown frame type: %@", frame);
            }
        }
        
    } taskTimeoutAssertions:nil];
}

- (void)DISABLE_testPlistSerializing {
//    __block BKRPlayableCassette *cassette = [[BKRPlayableCassette alloc] init];
//    __block NSMutableDictionary *actualCassetteDict = [NSMutableDictionary dictionary];
    
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
    [self getTaskWithURLString:@"https://httpbin.org/get?test=test" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        task.globallyUniqueIdentifier = taskUniqueIdentifier;
        XCTAssertNil(error);
        expectedCassetteDict[@"uniqueIdentifier"] = task.globallyUniqueIdentifier;
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        XCTAssertEqualObjects(dataDict[@"args"], @{@"test": @"test"});
        XCTAssertEqual([(NSHTTPURLResponse *)response statusCode], 200);
        // ensure that result from network is as expected
        
//        [self addTask:task data:data response:response error:error toPlayableCassette:ca]
        
//        NSDictionary *actualOriginalRequestFrameDict = [self dictionaryWithRequest:task.originalRequest forTask:task];
//        NSDictionary *actualCurrentRequestFrameDict = [self dictionaryWithRequest:task.currentRequest forTask:task];
//        NSDictionary *actualResponseFrameDict = [self dictionaryWithResponse:response forTask:task];
//        NSDictionary *actualDataFrameDict = [self dictionaryWithData:data forTask:task];
//        NSArray *actualFramesArray = @[
//                                       actualOriginalRequestFrameDict,
//                                       actualCurrentRequestFrameDict,
//                                       actualResponseFrameDict,
//                                       actualDataFrameDict
//                                       ];
//        NSDictionary *actualSceneDict = @{
//                                          @"uniqueIdentifier": task.globallyUniqueIdentifier,
//                                          @"frames": actualFramesArray
//                                          };
//        NSArray *actualScenesArray = @[
//                                       actualSceneDict
//                                       ];
//        cassetteDict[@"scenes"] = actualScenesArray;
        
        
        
    } taskTimeoutAssertions:nil];
}

@end
