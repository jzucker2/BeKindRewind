//
//  BKRRecordableVCRTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 2/15/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRRecordableVCR.h>
#import <BeKindRewind/BKRFilePathHelper.h>
#import <BeKindRewind/NSURLSessionTask+BKRAdditions.h>
#import <BeKindRewind/NSURLSessionTask+BKRTestAdditions.h>
#import <BeKindRewind/BKRCassette.h>
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
    
    // now remove anything at that path if there is something
    NSError *testResultRemovalError = nil;
    BOOL fileExists = [BKRFilePathHelper filePathExists:self.testRecordingFilePath];
    if (fileExists) {
        BOOL removeTestResults = [[NSFileManager defaultManager] removeItemAtPath:self.testRecordingFilePath error:&testResultRemovalError];
        XCTAssertTrue(removeTestResults);
        XCTAssertNil(testResultRemovalError, @"Couldn't remove test results: %@", testResultRemovalError.localizedDescription);
    }
    
    XCTAssertFalse([BKRFilePathHelper filePathExists:self.testRecordingFilePath]);
    
    if (self.invocation.selector == @selector(testFileCreatedWhenRecordingDisabledAndDefaultOverriddenInInit)) {
        self.vcr = [BKRRecordableVCR vcrWithCassetteSavingOption:YES];
    } else if (self.invocation.selector == @selector(testNoFileCreatedWhenRecordingDisabledAndEmptyFileSavingIsOff)) {
        self.vcr = [BKRRecordableVCR vcrWithCassetteSavingOption:NO];
    } else {
        self.vcr = [BKRRecordableVCR vcr];
    }
    
    [self setVCRBeginAndEndRecordingBlocks:self.vcr];
    [self insertCassetteFilePath:self.testRecordingFilePath intoVCR:self.vcr];
}

- (void)tearDown {
    [self resetVCR:self.vcr];
    [super tearDown];
}

- (void)testNoFileCreatedWhenRecordingDisabledAndEmptyFileSavingIsOff {
    BKRTestExpectedResult *result = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[result] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
    XCTAssertFalse([self ejectCassetteFromVCR:self.vcr]);
    XCTAssertFalse([BKRFilePathHelper filePathExists:self.testRecordingFilePath]);
}

- (void)testFileCreatedWhenRecordingDisabledAndDefaultOverriddenInInit {
    BKRTestExpectedResult *result = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[result] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
    XCTAssertTrue([self ejectCassetteFromVCR:self.vcr]);
    XCTAssertTrue([BKRFilePathHelper filePathExists:self.testRecordingFilePath]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[]];
}

- (void)testOffThenOn {
    BKRTestExpectedResult *result = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[result] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
    }];
    
    [self recordVCR:self.vcr];
    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[result] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.vcr.currentCassette.allScenes);
        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, 1);
    }];
    XCTAssertTrue([self ejectCassetteFromVCR:self.vcr]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[result]];
}

- (void)testOnThenOff {
    BKRTestExpectedResult *result = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    [self recordVCR:self.vcr];
    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[result] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.vcr.currentCassette.allScenes);
        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, 1);
    }];
    
    [self stopVCR:self.vcr];
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[result] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, 1);
    }];
    XCTAssertTrue([self ejectCassetteFromVCR:self.vcr]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[result]];
}

- (void)testRecordingOneGETRequest {
    BKRTestExpectedResult *expectedResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    [self recordVCR:self.vcr];
    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[expectedResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.vcr.currentCassette.allScenes);
        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, 1);
    }];
    XCTAssertTrue([self ejectCassetteFromVCR:self.vcr]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[expectedResult]];
}

- (void)testRecordingOneCancelledGETRequest {
    BKRTestExpectedResult *cancelledResult = [self HTTPBinCancelledRequestWithRecording:YES];
    [self recordVCR:self.vcr];
    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[cancelledResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.vcr.currentCassette.allScenes);
        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, 1);
    }];
    XCTAssertTrue([self ejectCassetteFromVCR:self.vcr]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[cancelledResult]];
}

- (void)testRecordingOnePOSTRequest {
    BKRTestExpectedResult *postResult = [self HTTPBinPostRequestWithRecording:YES];
    [self recordVCR:self.vcr];
    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[postResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        BKRStrongify(self);
        batchSceneAssertions(self.vcr.currentCassette.allScenes);
        XCTAssertEqual(self.vcr.currentCassette.allScenes.count, 1);
    }];
    XCTAssertTrue([self ejectCassetteFromVCR:self.vcr]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[postResult]];
}

- (void)testRecordingMultipleGETRequests {
    BKRTestExpectedResult *firstResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:YES];
    BKRTestExpectedResult *secondResult = [self HTTPBinGetRequestWithQueryString:@"test=test2" withRecording:YES];
    [self recordVCR:self.vcr];
    BKRWeakify(self);
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[firstResult, secondResult] withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
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
    XCTAssertTrue([self ejectCassetteFromVCR:self.vcr]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedResults:@[firstResult, secondResult]];
}

//- (void)testRecordingTwoConsecutiveGETRequestsWithSameRequestURLAndDifferentResponses {
//    BKRExpectedRecording *firstRecording = [BKRExpectedRecording recording];
//    firstRecording.URLString = @"https://pubsub.pubnub.com/time/0";
//    firstRecording.responseStatusCode = 200;
//    firstRecording.expectedSceneNumber = 0;
//    firstRecording.expectedNumberOfFrames = 4;
//    firstRecording.checkAgainstRecorder = NO;
//    
//    BKRExpectedRecording *secondRecording = [BKRExpectedRecording recording];
//    secondRecording.URLString = firstRecording.URLString;
//    secondRecording.responseStatusCode = 200;
//    secondRecording.expectedSceneNumber = 1;
//    secondRecording.expectedNumberOfFrames = 4;
//    secondRecording.checkAgainstRecorder = NO;
//    
//    __block XCTestExpectation *startRecordingExpectation = [self expectationWithDescription:@"start recording"];
//    [self.vcr recordWithCompletionBlock:^{
//        [startRecordingExpectation fulfill];
//    }];
//    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
//        XCTAssertNil(error);
//    }];
//    __block NSNumber *firstTimetoken = nil;
//    [self recordingTaskWithExpectedRecording:firstRecording taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//        // ensure that result from network is as expected
//        XCTAssertNotNil(dataArray);
//        firstTimetoken = dataArray.firstObject;
//        XCTAssertNotNil(firstTimetoken);
//        XCTAssertTrue([firstTimetoken isKindOfClass:[NSNumber class]]);
//        NSTimeInterval firstTimeTokenAsUnix = [self unixTimestampForPubNubTimetoken:firstTimetoken];
//        NSTimeInterval currentUnixTimestamp = [[NSDate date] timeIntervalSince1970];
//        XCTAssertEqualWithAccuracy(firstTimeTokenAsUnix, currentUnixTimestamp, 5);
//    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
//        //        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
//    }];
//    
//    [self recordingTaskWithExpectedRecording:secondRecording taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
//        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//        // ensure that result from network is as expected
//        XCTAssertNotNil(dataArray);
//        NSNumber *secondTimetoken = dataArray.firstObject;
//        XCTAssertNotNil(secondTimetoken);
//        XCTAssertTrue([secondTimetoken isKindOfClass:[NSNumber class]]);
//        NSTimeInterval secondTimeTokenAsUnix = [self unixTimestampForPubNubTimetoken:secondTimetoken];
//        NSTimeInterval currentUnixTimestamp = [[NSDate date] timeIntervalSince1970];
//        XCTAssertEqualWithAccuracy(secondTimeTokenAsUnix, currentUnixTimestamp, 5);
//        // also make sure that the two time tokens returned are different
//        XCTAssertNotEqualObjects(firstTimetoken, secondTimetoken);
//    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
//        //        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 2);
//    }];
//    
//    __block XCTestExpectation *ejectExpectation = [self expectationWithDescription:@"eject"];
//    XCTAssertTrue([self.vcr eject:YES completionHandler:^(BOOL result, NSString *filePath) {
//        [ejectExpectation fulfill];
//    }]);
//    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
//        XCTAssertNil(error);
//    }];
//    XCTAssertTrue([BKRFilePathHelper filePathExists:self.testRecordingFilePath]);
//    [self assertCassettePath:self.testRecordingFilePath matchesExpectedRecordings:@[firstRecording, secondRecording]];
//}

@end
