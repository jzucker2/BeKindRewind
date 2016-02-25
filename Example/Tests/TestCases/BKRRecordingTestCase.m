//
//  BKRRecordingTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/19/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

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

//- (void)testRecordingNoFileCreatedWhenRecordingDisabledAndEmptyFileSavingIsOff {
//    BKRTestExpectedResult *result = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[result] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//    }];
//    XCTAssertFalse([self ejectCassetteWithFilePath:self.testRecordingFilePath fromTestVCR:self.vcr]);
//    XCTAssertFalse([BKRFilePathHelper filePathExists:self.testRecordingFilePath]);
//}
//
//- (void)testRecordingFileCreatedWhenRecordingDisabledAndDefaultOverriddenInInit {
//    BKRTestExpectedResult *result = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[result] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//    }];
//    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromTestVCR:self.vcr]);
//    XCTAssertTrue([BKRFilePathHelper filePathExists:self.testRecordingFilePath]);
//    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[]];
//}
//
//- (void)testRecordingOffThenOn {
//    BKRTestExpectedResult *result = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[result] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//    }];
//    
//    [self recordTestVCR:self.vcr];
//    BKRWeakify(self);
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[result] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//        BKRStrongify(self);
//        batchSceneAssertions(self.vcr.currentCassette.allScenes);
//        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, 1);
//    }];
//    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromTestVCR:self.vcr]);
//    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[result]];
//}
//
//- (void)testRecordingOnThenOff {
//    BKRTestExpectedResult *result = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
//    [self recordTestVCR:self.vcr];
//    BKRWeakify(self);
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[result] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//        BKRStrongify(self);
//        batchSceneAssertions(self.vcr.currentCassette.allScenes);
//        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, 1);
//    }];
//    
//    [self stopTestVCR:self.vcr];
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[result] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//        BKRStrongify(self);
//        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, 1);
//    }];
//    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromTestVCR:self.vcr]);
//    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[result]];
//}

- (void)testRecordingOneGETRequest {
    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    self.expectedResults = @[expectedResult];
    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:self.expectedResults withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.currentVCR.currentCassette.allScenes);
        XCTAssertEqual(self.currentVCR.currentCassette.allScenes.count, 1);
    }];
//    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromTestVCR:self.vcr]);
//    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[expectedResult]];
}

- (void)testRecordingOneCancelledGETRequest {
    BKRTestExpectedResult *cancelledResult = [self HTTPBinCancelledRequestWithRecording:YES];
    self.expectedResults = @[cancelledResult];
    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:self.expectedResults.copy withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.currentVCR.currentCassette.allScenes);
        XCTAssertEqual(self.currentVCR.currentCassette.allScenes.count, 1);
    }];
//    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromTestVCR:self.vcr]);
//    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[cancelledResult]];
}

- (void)testRecordingOnePOSTRequest {
    BKRTestExpectedResult *postResult = [self HTTPBinPostRequestWithRecording:YES];
    self.expectedResults = @[postResult];
//    [self recordTestVCR:self.vcr];
    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:self.expectedResults withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.currentVCR.currentCassette.allScenes);
        XCTAssertEqual(self.currentVCR.currentCassette.allScenes.count, 1);
    }];
//    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromTestVCR:self.vcr]);
//    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[postResult]];
}

- (void)testRecordingMultipleGETRequests {
    BKRTestExpectedResult *firstResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    BKRTestExpectedResult *secondResult = [self HTTPBinGetRequestWithQueryString:@"test=test2" withRecording:YES];
//    [self recordTestVCR:self.vcr];
    self.expectedResults = @[firstResult, secondResult];
    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:self.expectedResults withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
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
//    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromTestVCR:self.vcr]);
//    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[firstResult, secondResult]];
}

- (void)testRecordingTwoConsecutiveGETRequestsWithSameRequestURLAndDifferentResponses {
    BKRTestExpectedResult *firstResult = [self PNGetTimeTokenWithRecording:YES];
    BKRTestExpectedResult *secondResult = [self PNGetTimeTokenWithRecording:YES];
//    [self recordTestVCR:self.vcr];
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
//    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromTestVCR:self.vcr]);
//    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[firstResult, secondResult]];
}

@end
