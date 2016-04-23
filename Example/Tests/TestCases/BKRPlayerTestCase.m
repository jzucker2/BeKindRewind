//
//  BKRPlayerTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 2/24/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRConfiguration.h>
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

- (void)testPlayerExecutesFailedRequestMatchingBlock {
    // This is the recording created for the cassette
    BKRTestExpectedResult *cassetteGETResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:NO];
    
    // create the player with a cassette with cassetteGETResult stored on it
    BKRConfiguration *configuration = [BKRConfiguration defaultConfiguration];
    // expectation variable is here so we can fulfill it in the configuration block, wait to create expectation
    __block XCTestExpectation *matchFailedExpectation = nil;
    configuration.requestMatchingFailedBlock = ^void (NSURLRequest *request) {
        [matchFailedExpectation fulfill];
    };
    BKRPlayer *player = [self playerWithConfiguration:configuration withExpectedResults:@[cassetteGETResult]];
    [self setPlayer:player withExpectationToEnabled:YES];
    
    // this expected result is "expected to be recorded" because it is live and does not match the result on the cassette
    BKRTestExpectedResult *unmatchedGETResult = [self HTTPBinGetRequestWithQueryString:@"test=test2" withRecording:YES];
    // create expectation now, before it used with the network request expectation
    matchFailedExpectation = [self expectationWithDescription:@"match failed expectation"];
    // now execute a network request for a different GET not matching the one on the cassette
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[unmatchedGETResult] simultaneously:NO withTaskCompletionAssertions:nil taskTimeoutHandler:nil];
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

- (void)testPlayingTwoSimultaneousGETRequests {
    BKRTestExpectedResult *firstResult = [self HTTPBinSimultaneousDelayedRequestWithDelay:2 withRecording:NO];
    BKRTestExpectedResult *secondResult = [self HTTPBinSimultaneousDelayedRequestWithDelay:3 withRecording:NO];
    
    __block BKRPlayer *player = [self playerWithExpectedResults:@[firstResult, secondResult]];
    XCTAssertEqual(player.allScenes.count, 2);
    [self setPlayer:player withExpectationToEnabled:YES];
    
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[firstResult, secondResult] simultaneously:YES withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions(player.allScenes);
    }];
}

- (void)testPlayingChunkedDataRequest {
    BKRTestExpectedResult *expectedResult = [self HTTPBinDripDataWithRecording:NO];
    
    __block BKRPlayer *player = [self playerWithExpectedResults:@[expectedResult]];
    XCTAssertEqual(player.allScenes.count, 1);
    [self setPlayer:player withExpectationToEnabled:YES];
    
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions(player.allScenes);
    }];
}

- (void)testPlayingRedirectRequest {
    BKRTestExpectedResult *expectedResult = [self HTTPBinRedirectWithRecording:NO];
    
    __block BKRPlayer *player = [self playerWithExpectedResults:@[expectedResult]];
    XCTAssertEqual(player.allScenes.count, 1);
    [self setPlayer:player withExpectationToEnabled:YES];
    
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        batchSceneAssertions(player.allScenes);
    }];
}

@end
