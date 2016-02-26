//
//  BKRPlayerTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 2/24/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRPlayer.h>
#import "XCTestCase+BKRHelpers.h"
#import "BKRBaseTestCase.h"

@interface BKRPlayerTestCase : BKRBaseTestCase

@end

@implementation BKRPlayerTestCase

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
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[getResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
    
    getResult.isRecording = NO;
    [self setPlayer:player withExpectationToEnabled:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[getResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions(player.allScenes);
    }];
}

- (void)testSwitchPlayerOnThenOff {
    BKRTestExpectedResult *getResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:NO];
    __block BKRPlayer *player = [self playerWithExpectedResults:@[getResult]];
    [self setPlayer:player withExpectationToEnabled:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[getResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions(player.allScenes);
    }];
    
    getResult.isRecording = YES;
    [self setPlayer:player withExpectationToEnabled:NO];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[getResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
}

- (void)testNoMockingWhenPlayerEnabledIsNotExplicitlySet {
    BKRTestExpectedResult *getResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    __block BKRPlayer *player = [self playerWithExpectedResults:@[getResult]];
    XCTAssertNotNil(player);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[getResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
}

- (void)testNoMockingWhenPlayerIsExplicitlyNotEnabled {
    BKRTestExpectedResult *getResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    __block BKRPlayer *player = [self playerWithExpectedResults:@[getResult]];
    [self setPlayer:player withExpectationToEnabled:NO];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[getResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
}

- (void)testPlayingOneGETRequest {
    BKRTestExpectedResult *getResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:NO];
    __block BKRPlayer *player = [self playerWithExpectedResults:@[getResult]];
    [self setPlayer:player withExpectationToEnabled:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[getResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions(player.allScenes);
    }];
}

- (void)testPlayingOneCancelledGETRequest {
    BKRTestExpectedResult *cancelledResult = [self HTTPBinCancelledRequestWithRecording:NO];
    __block BKRPlayer *player = [self playerWithExpectedResults:@[cancelledResult]];
    [self setPlayer:player withExpectationToEnabled:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[cancelledResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions(player.allScenes);
    }];
}

- (void)testPlayingOnePOSTRequest {
    BKRTestExpectedResult *postResult = [self HTTPBinPostRequestWithRecording:NO];
    __block BKRPlayer *player = [self playerWithExpectedResults:@[postResult]];
    [self setPlayer:player withExpectationToEnabled:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[postResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
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
    
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[firstResult, secondResult] simultaneously:NO withTaskCompletionAssertions:nil taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions(player.allScenes);
    }];
}

- (void)testPlayingTwoConsecutiveGETRequestsWithSameRequestURLAndDifferentResponses {
    BKRTestExpectedResult *firstResult = [self PNGetTimeTokenWithRecording:NO];
    BKRTestExpectedResult *secondResult = [self PNGetTimeTokenWithRecording:NO];
    
    __block BKRPlayer *player = [self playerWithExpectedResults:@[firstResult, secondResult]];
    XCTAssertEqual(player.allScenes.count, 2);
    [self setPlayer:player withExpectationToEnabled:YES];
    
    [self BKRTest_executePNTimeTokenNetworkCallsForExpectedResults:@[firstResult, secondResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions(player.allScenes);
    }];
}

- (void)DISABLE_testPlayingTwoSimultaneousGETRequests {
    BKRTestExpectedResult *firstResult = [self HTTPBinDelayedRequestWithDelay:2 withRecording:NO];
    BKRTestExpectedResult *secondResult = [self HTTPBinDelayedRequestWithDelay:3 withRecording:NO];
    
    __block BKRPlayer *player = [self playerWithExpectedResults:@[firstResult, secondResult]];
    XCTAssertEqual(player.allScenes.count, 2);
    [self setPlayer:player withExpectationToEnabled:YES];
    
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[firstResult, secondResult] simultaneously:YES withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"response: %@", response);
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions(player.allScenes);
    }];
}

@end
