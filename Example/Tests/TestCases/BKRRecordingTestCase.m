//
//  BKRRecordingTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/19/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRTestConfiguration.h>
#import <BeKindRewind/BKRTestCase.h>
#import <BeKindRewind/BKRCassette.h>
#import <BeKindRewind/BKRTestCaseFilePathHelper.h>
#import "XCTestCase+BKRHelpers.h"

@interface BKRRecordingTestCase : BKRTestCase
@property (nonatomic, strong) NSArray<BKRTestExpectedResult *> *expectedResults;
@end

@implementation BKRRecordingTestCase

- (BOOL)isRecording {
    return YES;
}

- (void)setUp {
    [super setUp];
    // Clear any existing recordings if they exist
    XCTAssertNotNil(self.currentVCR);
    NSString *filePath = [self recordingCassetteFilePathWithBaseDirectoryFilePath:[self baseFixturesDirectoryFilePath]];
    XCTAssertNotNil(filePath);
    [self assertNoFileAtRecordingCassetteFilePath:filePath];
}

- (void)tearDown {
    [super tearDown];
    // Now eject should have occurred, so let's test the eject results
    NSString *filePath = [self recordingCassetteFilePathWithBaseDirectoryFilePath:[self baseFixturesDirectoryFilePath]];
    XCTAssertNotNil(filePath);
    XCTAssertTrue([BKRTestCaseFilePathHelper filePathExists:filePath]);
    [self assertCassettePath:filePath matchesExpectedResults:self.expectedResults];
    self.expectedResults = nil;
}

- (void)testRecordingOneGETRequest {
    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    self.expectedResults = @[expectedResult];
    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:self.expectedResults simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.currentVCR.currentCassette.allScenes);
        XCTAssertEqual(self.currentVCR.currentCassette.allScenes.count, 1);
    }];
}

- (void)testRecordingOneCancelledGETRequest {
    BKRTestExpectedResult *cancelledResult = [self HTTPBinCancelledRequestWithRecording:YES];
    self.expectedResults = @[cancelledResult];
    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:self.expectedResults simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.currentVCR.currentCassette.allScenes);
        XCTAssertEqual(self.currentVCR.currentCassette.allScenes.count, 1);
    }];
}

- (void)testRecordingOnePOSTRequest {
    BKRTestExpectedResult *postResult = [self HTTPBinPostRequestWithRecording:YES];
    self.expectedResults = @[postResult];

    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:self.expectedResults simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.currentVCR.currentCassette.allScenes);
        XCTAssertEqual(self.currentVCR.currentCassette.allScenes.count, 1);
    }];
}

- (void)testRecordingMultipleGETRequests {
    BKRTestExpectedResult *firstResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    BKRTestExpectedResult *secondResult = [self HTTPBinGetRequestWithQueryString:@"test=test2" withRecording:YES];

    self.expectedResults = @[firstResult, secondResult];
    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:self.expectedResults simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.currentVCR.currentCassette.allScenes);
        NSInteger totalScenes = 0;
        if (result == firstResult) {
            totalScenes = 1;
        } else if (result == secondResult) {
            totalScenes = 2;
        }
        XCTAssertEqual(self.currentVCR.currentCassette.allScenes.count, totalScenes);
    }];
}

- (void)testRecordingTwoConsecutiveGETRequestsWithSameRequestURLAndDifferentResponses {
    BKRTestExpectedResult *firstResult = [self PNGetTimeTokenWithRecording:YES];
    BKRTestExpectedResult *secondResult = [self PNGetTimeTokenWithRecording:YES];

    self.expectedResults = @[firstResult, secondResult];
    
    BKRWeakify(self);
    [self BKRTest_executePNTimeTokenNetworkCallsForExpectedResults:self.expectedResults withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.currentVCR.currentCassette.allScenes);
        NSInteger totalScenes = 0;
        if (result == firstResult) {
            totalScenes = 1;
        } else if (result == secondResult) {
            totalScenes = 2;
        }
        XCTAssertEqual(self.currentVCR.currentCassette.allScenes.count, totalScenes);
    }];
}

- (void)testRecordingTwoSimultaneousGETRequests {
    BKRTestExpectedResult *firstResult = [self HTTPBinSimultaneousDelayedRequestWithDelay:2 withRecording:YES];
    BKRTestExpectedResult *secondResult = [self HTTPBinSimultaneousDelayedRequestWithDelay:3 withRecording:YES];
    
    self.expectedResults = @[firstResult, secondResult];
    
    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:self.expectedResults simultaneously:YES withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.currentVCR.currentCassette.allScenes);
        XCTAssertEqual(self.currentVCR.currentCassette.allScenes.count, 2);
    }];
}

- (void)testRecordingChunkedDataRequest {
    BKRTestExpectedResult *expectedResult = [self HTTPBinDripDataWithRecording:YES];
    
    self.expectedResults = @[expectedResult];
    
    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.currentVCR.currentCassette.allScenes);
        XCTAssertEqual(self.currentVCR.currentCassette.allScenes.count, 1);
    }];
}

- (void)testRecordingRedirectRequest {
    BKRTestExpectedResult *expectedResult = [self HTTPBinRedirectWithRecording:YES];
    
    self.expectedResults = @[expectedResult];
    
    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.currentVCR.currentCassette.allScenes);
        XCTAssertEqual(self.currentVCR.currentCassette.allScenes.count, 1);
    }];
}

@end
