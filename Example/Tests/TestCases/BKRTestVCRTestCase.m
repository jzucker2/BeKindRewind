//
//  BKRTestVCRTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 2/21/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRTestVCR.h>
#import <BeKindRewind/BKRCassette.h>
#import <BeKindRewind/BKRCassette+Playable.h>
#import <BeKindRewind/BKRFilePathHelper.h>
#import <BeKindRewind/BKRTestConfiguration.h>
#import "BKRBaseTestCase.h"
#import "XCTestCase+BKRHelpers.h"

@interface BKRTestVCRTestCase : BKRBaseTestCase
@property (nonatomic, strong) BKRTestVCR *vcr;
@property (nonatomic, copy) NSString *testRecordingFilePath;
@property (nonatomic, copy) NSString *testPlayingFilePath;
@end

@implementation BKRTestVCRTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSString *baseDirectory = [BKRFilePathHelper documentsDirectory];
    NSString *fileName = [NSStringFromSelector(self.invocation.selector) stringByAppendingPathExtension:@"plist"];
    self.testRecordingFilePath = [baseDirectory stringByAppendingPathComponent:fileName];
    XCTAssertNotNil(self.testRecordingFilePath);
    
    // now remove anything at that path if there is something
    NSError *testResultRemovalError = nil;
    BOOL fileExists = [BKRFilePathHelper filePathExists:self.testRecordingFilePath];
    if (fileExists) {
        BOOL removeTestResults = [[NSFileManager defaultManager] removeItemAtPath:self.testRecordingFilePath error:&testResultRemovalError];
        XCTAssertTrue(removeTestResults);
        XCTAssertNil(testResultRemovalError, @"Couldn't remove test results: %@", testResultRemovalError.localizedDescription);
    }
    
    XCTAssertFalse([BKRFilePathHelper filePathExists:self.testRecordingFilePath]);
    
    BKRTestConfiguration *configuration = [BKRTestConfiguration defaultConfigurationWithTestCase:self];
    if (self.invocation.selector == @selector(testRecordingFileCreatedWhenRecordingDisabledAndDefaultOverriddenInInit)) {
//        self.vcr = [self vcrWithPlayheadMatcherAndCassetteSavingOption:YES];
        configuration.shouldSaveEmptyCassette = YES;
        self.vcr = [BKRTestVCR vcrWithTestConfiguration:configuration];
    } else if (self.invocation.selector == @selector(testRecordingNoFileCreatedWhenRecordingDisabledAndEmptyFileSavingIsOff)) {
        configuration.shouldSaveEmptyCassette = NO;
//        self.vcr = [self vcrWithPlayheadMatcherAndCassetteSavingOption:NO];
        self.vcr = [BKRTestVCR vcrWithTestConfiguration:configuration];
    } else {
//        self.vcr = [self vcrWithPlayheadMatcherAndCassetteSavingOption:NO];
        self.vcr = [BKRTestVCR defaultVCRForTestCase:self];
    }
    
    NSString *testSelectorString = NSStringFromSelector(self.invocation.selector);
    if ([testSelectorString hasPrefix:@"testRecording"]) {
//        [self insertBlankCassetteIntoVCR:self.vcr];
        [self insertBlankCassetteIntoTestVCR:self.vcr];
        XCTAssertEqual(self.vcr.state, BKRVCRStateStopped);
    } else if ([testSelectorString hasPrefix:@"testPlaying"]) {
        self.testPlayingFilePath = [BKRFilePathHelper findPathForFile:fileName inBundleForClass:self.class];
        XCTAssertNotNil(self.testPlayingFilePath);
        XCTAssertTrue([BKRFilePathHelper filePathExists:self.testPlayingFilePath]);
//        [self insertCassetteFilePath:self.testPlayingFilePath intoVCR:self.vcr];
        [self insertCassetteFilePath:self.testPlayingFilePath intoTestVCR:self.vcr];
        XCTAssertEqual(self.vcr.state, BKRVCRStateStopped);
    } else {
        XCTFail(@"Not prepared to handle this sort of test case: %@", testSelectorString);
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self resetTestVCR:self.vcr];
    XCTAssertEqual(self.vcr.state, BKRVCRStateStopped);
    [super tearDown];
}

- (void)testRecordingNoFileCreatedWhenRecordingDisabledAndEmptyFileSavingIsOff {
    BKRTestExpectedResult *result = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[result] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
    XCTAssertFalse([self ejectCassetteWithFilePath:self.testRecordingFilePath fromTestVCR:self.vcr]);
    XCTAssertEqual(self.vcr.state, BKRVCRStateStopped);
    XCTAssertFalse([BKRFilePathHelper filePathExists:self.testRecordingFilePath]);
}

- (void)testRecordingFileCreatedWhenRecordingDisabledAndDefaultOverriddenInInit {
    BKRTestExpectedResult *result = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[result] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromTestVCR:self.vcr]);
    XCTAssertTrue([BKRFilePathHelper filePathExists:self.testRecordingFilePath]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[]];
}

//- (void)testRecordingOffThenOn {
//    BKRTestExpectedResult *result = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[result] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//    }];
//    
//    [self recordVCR:self.vcr];
//    BKRWeakify(self);
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[result] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//        BKRStrongify(self);
//        batchSceneAssertions(self.vcr.currentCassette.allScenes);
//        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, 1);
//    }];
//    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromVCR:self.vcr]);
//    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[result]];
//}
//
//- (void)testRecordingOnThenOff {
//    BKRTestExpectedResult *result = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
//    [self recordVCR:self.vcr];
//    BKRWeakify(self);
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[result] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//        BKRStrongify(self);
//        batchSceneAssertions(self.vcr.currentCassette.allScenes);
//        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, 1);
//    }];
//    
//    [self stopVCR:self.vcr];
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[result] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//        BKRStrongify(self);
//        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, 1);
//    }];
//    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromVCR:self.vcr]);
//    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[result]];
//}
//
//- (void)testRecordingOneGETRequest {
//    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
//    [self recordVCR:self.vcr];
//    BKRWeakify(self);
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//        BKRStrongify(self);
//        batchSceneAssertions(self.vcr.currentCassette.allScenes);
//        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, 1);
//    }];
//    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromVCR:self.vcr]);
//    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[expectedResult]];
//}
//
//- (void)testRecordingOneCancelledGETRequest {
//    BKRTestExpectedResult *cancelledResult = [self HTTPBinCancelledRequestWithRecording:YES];
//    [self recordVCR:self.vcr];
//    BKRWeakify(self);
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[cancelledResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//        BKRStrongify(self);
//        batchSceneAssertions(self.vcr.currentCassette.allScenes);
//        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, 1);
//    }];
//    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromVCR:self.vcr]);
//    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[cancelledResult]];
//}
//
//- (void)testRecordingOnePOSTRequest {
//    BKRTestExpectedResult *postResult = [self HTTPBinPostRequestWithRecording:YES];
//    [self recordVCR:self.vcr];
//    BKRWeakify(self);
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[postResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//        BKRStrongify(self);
//        batchSceneAssertions(self.vcr.currentCassette.allScenes);
//        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, 1);
//    }];
//    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromVCR:self.vcr]);
//    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[postResult]];
//}
//
//- (void)testRecordingMultipleGETRequests {
//    BKRTestExpectedResult *firstResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
//    BKRTestExpectedResult *secondResult = [self HTTPBinGetRequestWithQueryString:@"test=test2" withRecording:YES];
//    [self recordVCR:self.vcr];
//    BKRWeakify(self);
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[firstResult, secondResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//        BKRStrongify(self);
//        batchSceneAssertions(self.vcr.currentCassette.allScenes);
//        NSInteger totalScenes = 0;
//        if (result == firstResult) {
//            totalScenes = 1;
//        } else if (result == secondResult) {
//            totalScenes = 2;
//        }
//        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, totalScenes);
//    }];
//    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromVCR:self.vcr]);
//    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[firstResult, secondResult]];
//}
//
//- (void)testRecordingTwoConsecutiveGETRequestsWithSameRequestURLAndDifferentResponses {
//    BKRTestExpectedResult *firstResult = [self PNGetTimeTokenWithRecording:YES];
//    BKRTestExpectedResult *secondResult = [self PNGetTimeTokenWithRecording:YES];
//    [self recordVCR:self.vcr];
//    
//    BKRWeakify(self);
//    [self BKRTest_executePNTimeTokenNetworkCallsForExpectedResults:@[firstResult, secondResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//        BKRStrongify(self);
//        batchSceneAssertions(self.vcr.currentCassette.allScenes);
//        NSInteger totalScenes = 0;
//        if (result == firstResult) {
//            totalScenes = 1;
//        } else if (result == secondResult) {
//            totalScenes = 2;
//        }
//        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, totalScenes);
//    }];
//    XCTAssertTrue([self ejectCassetteWithFilePath:self.testRecordingFilePath fromVCR:self.vcr]);
//    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[firstResult, secondResult]];
//}
//
//// the fixture for this exists, and is asserted in the setUp
//- (void)testPlayingNoMockingWhenVCRIsNotSentPlay {
//    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//    }];
//}
//
//- (void)testPlayingOffThenOn {
//    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//    }];
//    expectedResult.isRecording = NO; // flip expected result to not recording for asserts
//    [self playVCR:self.vcr];
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//    }];
//}
//
//- (void)testPlayingOnThenOff {
//    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:NO];
//    [self playVCR:self.vcr];
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//    }];
//    expectedResult.isRecording = YES; // flip expected result to recording for asserts
//    [self stopVCR:self.vcr];
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//    }];
//}
//
//- (void)testPlayingOneGETRequest {
//    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:NO];
//    [self playVCR:self.vcr];
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//    }];
//}
//
//- (void)testPlayingOneCancelledGETRequest {
//    BKRTestExpectedResult *cancelledRequest = [self HTTPBinCancelledRequestWithRecording:NO];
//    [self playVCR:self.vcr];
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[cancelledRequest] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//    }];
//}
//
//- (void)testPlayingOnePOSTRequest {
//    BKRTestExpectedResult *postResult = [self HTTPBinPostRequestWithRecording:NO];
//    [self playVCR:self.vcr];
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[postResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//    }];
//}
//
//- (void)testPlayingMultipleGETRequests {
//    BKRTestExpectedResult *firstResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:NO];
//    BKRTestExpectedResult *secondResult = [self HTTPBinGetRequestWithQueryString:@"test=test2" withRecording:NO];
//    [self playVCR:self.vcr];
//    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[firstResult, secondResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//    }];
//}
//
//- (void)testPlayingTwoConsecutiveGETRequestsWithSameRequestURLAndDifferentResponses {
//    BKRTestExpectedResult *firstResult = [self PNGetTimeTokenWithRecording:NO];
//    BKRTestExpectedResult *secondResult = [self PNGetTimeTokenWithRecording:NO];
//    
//    [self playVCR:self.vcr];
//    
//    [self BKRTest_executePNTimeTokenNetworkCallsForExpectedResults:@[firstResult, secondResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
//    }];
//}

@end
