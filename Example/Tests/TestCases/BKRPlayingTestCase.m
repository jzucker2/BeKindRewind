//
//  BKRPlayingTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/22/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRPlayer.h>
#import <BeKindRewind/BKRCassette+Playable.h>
#import <BeKindRewind/BKRScene.h>
#import "XCTestCase+BKRHelpers.h"
#import "BKRBaseTestCase.h"

@interface BKRPlayingTestCase : BKRBaseTestCase

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

- (void)testSwitchPlayingOffThenOn {
    BKRTestExpectedResult *getResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    __block BKRPlayer *player = [self playerWithExpectedResults:@[getResult]];
    [self setPlayer:player withExpectationToEnabled:NO];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[getResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
    
    getResult.isRecording = NO;
    [self setPlayer:player withExpectationToEnabled:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[getResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions(player.allScenes);
    }];
}

- (void)testSwitchPlayerOnThenOff {
    BKRTestExpectedResult *getResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:NO];
    __block BKRPlayer *player = [self playerWithExpectedResults:@[getResult]];
    [self setPlayer:player withExpectationToEnabled:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[getResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions(player.allScenes);
    }];
    
    getResult.isRecording = YES;
    [self setPlayer:player withExpectationToEnabled:NO];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[getResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
}

- (void)testNoMockingWhenPlayerEnabledIsNotExplicitlySet {
    BKRTestExpectedResult *getResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    __block BKRPlayer *player = [self playerWithExpectedResults:@[getResult]];
    XCTAssertNotNil(player);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[getResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
}

- (void)testNoMockingWhenPlayerIsExplicitlyNotEnabled {
    BKRTestExpectedResult *getResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    __block BKRPlayer *player = [self playerWithExpectedResults:@[getResult]];
    [self setPlayer:player withExpectationToEnabled:NO];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[getResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
}

- (void)testPlayingOneGETRequest {
    BKRTestExpectedResult *getResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:NO];
    __block BKRPlayer *player = [self playerWithExpectedResults:@[getResult]];
    [self setPlayer:player withExpectationToEnabled:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[getResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions(player.allScenes);
    }];
}

- (void)testPlayingOneCancelledGETRequest {
    BKRTestExpectedResult *cancelledResult = [self HTTPBinCancelledRequestWithRecording:NO];
    __block BKRPlayer *player = [self playerWithExpectedResults:@[cancelledResult]];
    [self setPlayer:player withExpectationToEnabled:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[cancelledResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions(player.allScenes);
    }];
}

- (void)testPlayingOnePOSTRequest {
    BKRTestExpectedResult *postResult = [self HTTPBinPostRequestWithRecording:NO];
    __block BKRPlayer *player = [self playerWithExpectedResults:@[postResult]];
    [self setPlayer:player withExpectationToEnabled:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[postResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions(player.allScenes);
    }];
}

- (void)testPlayingMultipleGetRequests {
    BKRTestExpectedResult *firstResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:NO];
    BKRTestExpectedResult *secondResult = [self HTTPBinGetRequestWithQueryString:@"test=test2" withRecording:NO];
    
    __block BKRPlayer *player = [self playerWithExpectedResults:@[firstResult, secondResult]];
    XCTAssertEqual(player.allScenes.count, 2);
    [self setPlayer:player withExpectationToEnabled:YES];
    
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[firstResult, secondResult] withTaskCompletionAssertions:nil taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions(player.allScenes);
    }];
}

//- (void)testPlayingTwoConsecutiveGETRequestsWithSameRequestURLAndDifferentResponses {
//    NSString *URLString = @"https://pubsub.pubnub.com/time/0";
//    NSString *firstTaskUniqueIdentifier = [NSUUID UUID].UUIDString;
//    BKRExpectedScenePlistDictionaryBuilder *firstSceneBuilder = [BKRExpectedScenePlistDictionaryBuilder builder];
//    firstSceneBuilder.URLString = URLString;
//    firstSceneBuilder.taskUniqueIdentifier = firstTaskUniqueIdentifier;
////    firstSceneBuilder.currentRequestAllHTTPHeaderFields = @{
////                                                            @"Accept": @"*/*",
////                                                            @"Accept-Encoding": @"gzip, deflate",
////                                                            @"Accept-Language": @"en-us"
////                                                            };
//    firstSceneBuilder.currentRequestAllHTTPHeaderFields = @{};
//    // technically the value returned is much larger, to save effort, using string so there's no math or rounding/casting issues
//    NSString *firstTimetoken = @"1454015931.93";
//    firstSceneBuilder.receivedJSON = @[firstTimetoken];
//    firstSceneBuilder.responseAllHeaderFields = @{
//                                                  @"Access-Control-Allow-Methods": @"GET",
//                                                  @"Access-Control-Allow-Origin": @"*",
//                                                  @"Cache-Control": @"no-cache",
//                                                  @"Connection": @"keep-alive",
//                                                  @"Content-Length": @"19",
//                                                  @"Content-Type": @"text/javascript; charset=\"UTF-8\"",
//                                                  @"Date": @"Wed, 27 Jan 2016 23:39:04 GMT",
//                                                  };
//    
//    NSString *secondTaskUniqueIdentifier = [NSUUID UUID].UUIDString;
//    BKRExpectedScenePlistDictionaryBuilder *secondSceneBuilder = [BKRExpectedScenePlistDictionaryBuilder builder];
//    secondSceneBuilder.URLString = URLString;
//    secondSceneBuilder.taskUniqueIdentifier = secondTaskUniqueIdentifier;
////    secondSceneBuilder.currentRequestAllHTTPHeaderFields = @{
////                                                             @"Accept": @"*/*",
////                                                             @"Accept-Encoding": @"gzip, deflate",
////                                                             @"Accept-Language": @"en-us"
////                                                             };
//    secondSceneBuilder.currentRequestAllHTTPHeaderFields = @{};
//    // technically the value returned is much larger, to save effort, using string so there's no math or rounding/casting issues
//    NSString *secondTimeToken = @"1454015935.93";
//    XCTAssertNotEqualObjects(firstTimetoken, secondTimeToken);
//    secondSceneBuilder.receivedJSON = @[secondTimeToken];
//    secondSceneBuilder.responseAllHeaderFields = @{
//                                                   @"Access-Control-Allow-Methods": @"GET",
//                                                   @"Access-Control-Allow-Origin": @"*",
//                                                   @"Cache-Control": @"no-cache",
//                                                   @"Connection": @"keep-alive",
//                                                   @"Content-Length": @"19",
//                                                   @"Content-Type": @"text/javascript; charset=\"UTF-8\"",
//                                                   @"Date": @"Wed, 27 Jan 2016 23:39:07 GMT",
//                                                   };
//    
//    NSDictionary *expectedCassetteDict = [self expectedCassetteDictionaryWithSceneBuilders:@[firstSceneBuilder, secondSceneBuilder]];
//    __block BKRScene *firstScene = nil;
//    __block BKRScene *secondScene = nil;
//    BKRCassette *testCassette = [[BKRCassette alloc] initFromPlistDictionary:expectedCassetteDict];
//    XCTAssertEqual(testCassette.allScenes.count, 2, @"testCassette should have one valid scene right now");
//    XCTAssertEqual(testCassette.allScenes.firstObject.allFrames.count, 4, @"testCassette should have 4 frames for it's 1st scene");
//    XCTAssertEqual(testCassette.allScenes.lastObject.allFrames.count, 4, @"testCassette should have 4 frames for it's 2nd scene");
//    __block BKRPlayer *player = [BKRPlayer playerWithMatcherClass:[BKRPlayheadMatcher class]];
////    player.currentCassette = testCassette;
//    [self setWithExpectationsPlayableCassette:testCassette inPlayer:player];
//    __block XCTestExpectation *enabledExpectation = [self expectationWithDescription:@"enable expectation"];
//    [player setEnabled:YES withCompletionHandler:^{
//        [enabledExpectation fulfill];
//    }];
//    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
//        XCTAssertNil(error);
//    }];
//    [self getTaskWithURLString:firstSceneBuilder.URLString taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        XCTAssertNil(error);
//        XCTAssertNotNil(data);
//        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//        XCTAssertNotNil(dataArray);
//        // ensure that result from network is as expected
//        NSNumber *receivedTimeToken = dataArray.firstObject;
//        XCTAssertEqualObjects(receivedTimeToken, firstTimetoken);
//        XCTAssertEqual([(NSHTTPURLResponse *)response statusCode], 200);
//        // now current cassette in recoder should have one scene with data matching this
//        XCTAssertNotNil(player.currentCassette);
//        XCTAssertEqual(player.allScenes.count, 2);
//        firstScene = (BKRScene *)player.allScenes.firstObject;
//        XCTAssertEqualObjects(firstScene.uniqueIdentifier, firstTaskUniqueIdentifier);
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
//    [self getTaskWithURLString:secondSceneBuilder.URLString taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        XCTAssertNil(error);
//        XCTAssertNotNil(data);
//        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//        XCTAssertNotNil(dataArray);
//        // ensure that result from network is as expected
//        NSNumber *receivedTimeToken = dataArray.firstObject;
//        XCTAssertEqualObjects(receivedTimeToken, secondTimeToken);
//        XCTAssertNotEqualObjects(receivedTimeToken, firstTimetoken);
//        XCTAssertEqual([(NSHTTPURLResponse *)response statusCode], 200);
//        // now current cassette in recoder should have one scene with data matching this
//        XCTAssertNotNil(player.currentCassette);
//        XCTAssertEqual(player.allScenes.count, 2);
//        secondScene = (BKRScene *)player.allScenes.lastObject;
//        XCTAssertEqualObjects(secondScene.uniqueIdentifier, secondTaskUniqueIdentifier);
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
//        NSURLRequest *originalRequest = task.originalRequest;
//        BKRRequestFrame *originalRequestFrame = secondScene.originalRequest;
//        XCTAssertNotNil(originalRequestFrame);
//        [self assertRequest:originalRequestFrame withRequest:originalRequest extraAssertions:nil];
//        XCTAssertNotNil(secondScene.currentRequest);
//        [self assertRequest:secondScene.currentRequest withRequest:task.currentRequest extraAssertions:nil];
//        [self assertFramesOrder:secondScene extraAssertions:nil];
//    }];
//}

@end
