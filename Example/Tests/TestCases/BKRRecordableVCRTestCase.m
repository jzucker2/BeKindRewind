//
//  BKRRecordableVCRTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 2/15/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRRecordableVCR.h>
#import <BeKindRewind/BKRFilePathHelper.h>
#import <BeKindRewind/BKRCassette.h>
#import <BeKindRewind/BKRConfiguration.h>
#import "BKRBaseTestCase.h"
#import "XCTestCase+BKRHelpers.h"

@interface BKRRecordableVCRTestCase : BKRBaseTestCase
@property (nonatomic, copy) NSString *testRecordingFilePath;
@property (nonatomic, strong) BKRRecordableVCR *vcr;
@end

@implementation BKRRecordableVCRTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSString *baseDirectory = [BKRFilePathHelper documentsDirectory];
    NSString *fileName = [NSStringFromSelector(self.invocation.selector) stringByAppendingPathExtension:@"plist"];
    self.testRecordingFilePath = [baseDirectory stringByAppendingPathComponent:fileName];
    XCTAssertNotNil(self.testRecordingFilePath);
    
    [self assertNoFileAtRecordingCassetteFilePath:self.testRecordingFilePath];
    
    BKRConfiguration *configuration = [self defaultConfiguration];
    if (self.invocation.selector == @selector(testRecordingFileCreatedWhenRecordingDisabledAndDefaultOverriddenInInit)) {
        configuration.shouldSaveEmptyCassette = YES;
        self.vcr = [BKRRecordableVCR vcrWithConfiguration:configuration];
    } else if (self.invocation.selector == @selector(testRecordingNoFileCreatedWhenRecordingDisabledAndEmptyFileSavingIsOff)) {
        configuration.shouldSaveEmptyCassette = NO;
        self.vcr = [BKRRecordableVCR vcrWithConfiguration:configuration];
    } else {
        self.vcr = [BKRRecordableVCR defaultVCR];
    }
    
    XCTAssertNotNil(self.vcr);
    
    [self insertBlankCassetteIntoVCR:self.vcr];
}

- (void)tearDown {
    [self resetVCR:self.vcr];
    [super tearDown];
}

- (void)testRecordingNoFileCreatedWhenRecordingDisabledAndEmptyFileSavingIsOff {
    BKRTestExpectedResult *result = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[result] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
    XCTAssertFalse([self ejectCassetteWithFilePath:self.testRecordingFilePath fromVCR:self.vcr]);
    XCTAssertFalse([BKRFilePathHelper filePathExists:self.testRecordingFilePath]);
}

- (void)testRecordingFileCreatedWhenRecordingDisabledAndDefaultOverriddenInInit {
    BKRTestExpectedResult *result = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[result] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromVCR:self.vcr]);
    XCTAssertTrue([BKRFilePathHelper filePathExists:self.testRecordingFilePath]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[]];
}

- (void)testRecordingFileCreatedWithNoNetworkActivityAndDefaultConfiguration {
    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromVCR:self.vcr]);
    XCTAssertTrue([BKRFilePathHelper filePathExists:self.testRecordingFilePath]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[]];
}

- (void)testRecordingOffThenOn {
    BKRTestExpectedResult *result = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[result] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
    
    [self recordVCR:self.vcr];
    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[result] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.vcr.currentCassette.allScenes);
        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, 1);
    }];
    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromVCR:self.vcr]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[result]];
}

- (void)testRecordingOnThenOff {
    BKRTestExpectedResult *result = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    [self recordVCR:self.vcr];
    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[result] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.vcr.currentCassette.allScenes);
        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, 1);
    }];
    
    [self stopVCR:self.vcr];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[result] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, 1);
    }];
    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromVCR:self.vcr]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[result]];
}

- (void)testRecordingOneGETRequest {
    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    [self recordVCR:self.vcr];
    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.vcr.currentCassette.allScenes);
        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, 1);
    }];
    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromVCR:self.vcr]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[expectedResult]];
}

- (void)testRecordingOneCancelledGETRequest {
    BKRTestExpectedResult *cancelledResult = [self HTTPBinCancelledRequestWithRecording:YES];
    [self recordVCR:self.vcr];
    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[cancelledResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.vcr.currentCassette.allScenes);
        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, 1);
    }];
    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromVCR:self.vcr]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[cancelledResult]];
}

- (void)testRecordingOnePOSTRequest {
    BKRTestExpectedResult *postResult = [self HTTPBinPostRequestWithRecording:YES];
    [self recordVCR:self.vcr];
    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[postResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.vcr.currentCassette.allScenes);
        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, 1);
    }];
    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromVCR:self.vcr]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[postResult]];
}

- (void)testRecordingMultipleGETRequests {
    BKRTestExpectedResult *firstResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    BKRTestExpectedResult *secondResult = [self HTTPBinGetRequestWithQueryString:@"test=test2" withRecording:YES];
    [self recordVCR:self.vcr];
    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[firstResult, secondResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.vcr.currentCassette.allScenes);
        NSInteger totalScenes = 0;
        if (result == firstResult) {
            totalScenes = 1;
        } else if (result == secondResult) {
            totalScenes = 2;
        }
        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, totalScenes);
    }];
    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromVCR:self.vcr]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[firstResult, secondResult]];
}

- (void)testRecordingTwoConsecutiveGETRequestsWithSameRequestURLAndDifferentResponses {
    BKRTestExpectedResult *firstResult = [self PNGetTimeTokenWithRecording:YES];
    BKRTestExpectedResult *secondResult = [self PNGetTimeTokenWithRecording:YES];
    [self recordVCR:self.vcr];
    
    BKRWeakify(self);
    [self BKRTest_executePNTimeTokenNetworkCallsForExpectedResults:@[firstResult, secondResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.vcr.currentCassette.allScenes);
        NSInteger totalScenes = 0;
        if (result == firstResult) {
            totalScenes = 1;
        } else if (result == secondResult) {
            totalScenes = 2;
        }
        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, totalScenes);
    }];
    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromVCR:self.vcr]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[firstResult, secondResult]];
}

- (void)testRecordingTwoSimultaneousGETRequests {    
    BKRTestExpectedResult *firstResult = [self HTTPBinSimultaneousDelayedRequestWithDelay:2 withRecording:YES];
    BKRTestExpectedResult *secondResult = [self HTTPBinSimultaneousDelayedRequestWithDelay:3 withRecording:YES];
    
    [self recordVCR:self.vcr];
    
    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[firstResult, secondResult] simultaneously:YES withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.vcr.currentCassette.allScenes);
        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, 2);
    }];
    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromVCR:self.vcr]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[firstResult, secondResult]];
}

- (void)testRecordingChunkedDataRequest {
    BKRTestExpectedResult *expectedResult = [self HTTPBinDripDataWithRecording:YES];
    
    [self recordVCR:self.vcr];
    
    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.vcr.currentCassette.allScenes);
        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, 1);
    }];
    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromVCR:self.vcr]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[expectedResult]];
}

- (void)testRecordingRedirectRequest {
    BKRTestExpectedResult *expectedResult = [self HTTPBinRedirectWithRecording:YES];
    
    [self recordVCR:self.vcr];
    
    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] simultaneously:NO withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.vcr.currentCassette.allScenes);
        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, 1);
    }];
    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromVCR:self.vcr]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[expectedResult]];
}

@end
