//
//  BKRVCRRecordableVCRTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 2/12/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRRecordableVCR.h>
#import <BeKindRewind/BKRFilePathHelper.h>
#import <BeKindRewind/NSURLSessionTask+BKRAdditions.h>
#import <BeKindRewind/NSURLSessionTask+BKRTestAdditions.h>
#import "BKRBaseTestCase.h"
#import "XCTestCase+BKRAdditions.h"

@interface BKRVCRRecordableVCRTestCase : BKRBaseTestCase
@property (nonatomic, copy) NSString *testRecordingFilePath;
@property (nonatomic, strong) BKRRecordableVCR *vcr;
@end

@implementation BKRVCRRecordableVCRTestCase

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
    
    self.vcr = [BKRRecordableVCR vcr];
    XCTAssertNotNil(self.vcr);
    
    BKRWeakify(self);
    self.vcr.beginRecordingBlock = ^void(NSURLSessionTask *task) {
        BKRStrongify(self);
        NSString *recordingExpectationString = [NSString stringWithFormat:@"Task: %@", task.globallyUniqueIdentifier];
        task.recordingExpectation = [self expectationWithDescription:recordingExpectationString];
    };
    
    self.vcr.endRecordingBlock = ^void(NSURLSessionTask *task) {
        [task.recordingExpectation fulfill];
    };
    
    __block XCTestExpectation *insertExpectation = [self expectationWithDescription:@"insert expectation"];
    XCTAssertTrue([self.vcr insert:self.testRecordingFilePath completionHandler:^(BOOL result, NSString *filePath) {
        [insertExpectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    //    [self.vcr reset];
    //    NSError *testResultRemovalError = nil;
    //    BOOL removeTestResults = [[NSFileManager defaultManager] removeItemAtPath:self.testRecordingFilePath error:&testResultRemovalError];
    //    XCTAssertTrue(removeTestResults);
    //    XCTAssertNil(testResultRemovalError, @"Couldn't remove test results: %@", testResultRemovalError.localizedDescription);
    __block XCTestExpectation *resetExpectation = [self expectationWithDescription:@"reset expectation"];
    [self.vcr resetWithCompletionBlock:^{
        [resetExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    [super tearDown];
}

- (void)testRecordingOneGETRequest {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    BKRExpectedRecording *expectedRecording = [BKRExpectedRecording recording];
    expectedRecording.URLString = @"https://httpbin.org/get?test=test";
    expectedRecording.receivedJSON = @{
                                       @"test": @"test"
                                       };
    expectedRecording.responseStatusCode = 200;
    expectedRecording.expectedSceneNumber = 0;
    expectedRecording.expectedNumberOfFrames = 4;
    expectedRecording.checkAgainstRecorder = NO;
    __block XCTestExpectation *startRecordingExpectation = [self expectationWithDescription:@"start recording"];
    [self.vcr recordWithCompletionBlock:^{
        [startRecordingExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    [self recordingTaskForHTTPBinWithExpectedRecording:expectedRecording taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        
    }];
    
    __block XCTestExpectation *ejectExpectation = [self expectationWithDescription:@"eject"];
    XCTAssertTrue([self.vcr eject:YES completionHandler:^(BOOL result, NSString *filePath) {
        [ejectExpectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    XCTAssertTrue([BKRFilePathHelper filePathExists:self.testRecordingFilePath]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedRecordings:@[expectedRecording]];
}

- (void)testRecordingOneCancelledGETRequest {
    BKRExpectedRecording *recording = [BKRExpectedRecording recording];
    recording.cancelling = YES;
    recording.URLString = @"https://httpbin.org/delay/10";
    recording.expectedSceneNumber = 0;
    recording.expectedNumberOfFrames = 2;
    recording.expectedErrorCode = -999;
    recording.expectedErrorDomain = NSURLErrorDomain;
    recording.checkAgainstRecorder = NO;
    recording.expectedErrorUserInfo = @{
                                        NSURLErrorFailingURLErrorKey: [NSURL URLWithString:recording.URLString],
                                        NSURLErrorFailingURLStringErrorKey: recording.URLString,
                                        NSLocalizedDescriptionKey: @"cancelled"
                                        };
    __block XCTestExpectation *startRecordingExpectation = [self expectationWithDescription:@"start recording"];
    [self.vcr recordWithCompletionBlock:^{
        [startRecordingExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    [self recordingTaskForHTTPBinWithExpectedRecording:recording taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
    }];
    
    __block XCTestExpectation *ejectExpectation = [self expectationWithDescription:@"eject"];
    XCTAssertTrue([self.vcr eject:YES completionHandler:^(BOOL result, NSString *filePath) {
        [ejectExpectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    XCTAssertTrue([BKRFilePathHelper filePathExists:self.testRecordingFilePath]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedRecordings:@[recording]];
}

- (void)testRecordingOnePOSTRequest {
    BKRExpectedRecording *recording = [BKRExpectedRecording recording];
    recording.URLString = @"https://httpbin.org/post";
    recording.expectedNumberOfFrames = 4;
    recording.expectedSceneNumber = 0;
    recording.responseStatusCode = 200;
    recording.HTTPMethod = @"POST";
    recording.receivedJSON = @{};
    recording.checkAgainstRecorder = NO;
    recording.sentJSON = @{
                           @"foo": @"bar"
                           };
    __block XCTestExpectation *startRecordingExpectation = [self expectationWithDescription:@"start recording"];
    [self.vcr recordWithCompletionBlock:^{
        [startRecordingExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    [self recordingTaskForHTTPBinWithExpectedRecording:recording taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
    }];
    __block XCTestExpectation *ejectExpectation = [self expectationWithDescription:@"eject"];
    XCTAssertTrue([self.vcr eject:YES completionHandler:^(BOOL result, NSString *filePath) {
        [ejectExpectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    XCTAssertTrue([BKRFilePathHelper filePathExists:self.testRecordingFilePath]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedRecordings:@[recording]];
}

- (void)testRecordingMultipleGETRequests {
    BKRExpectedRecording *firstRecording = [BKRExpectedRecording recording];
    firstRecording.URLString = @"https://httpbin.org/get?test=test";
    firstRecording.receivedJSON = @{
                                    @"test": @"test"
                                    };
    firstRecording.responseStatusCode = 200;
    firstRecording.expectedSceneNumber = 0;
    firstRecording.expectedNumberOfFrames = 4;
    firstRecording.checkAgainstRecorder = NO;
    
    BKRExpectedRecording *secondRecording = [BKRExpectedRecording recording];
    secondRecording.URLString = @"https://httpbin.org/get?test=test2";
    secondRecording.receivedJSON = @{
                                     @"test": @"test2"
                                     };
    secondRecording.responseStatusCode = 200;
    secondRecording.expectedSceneNumber = 1;
    secondRecording.expectedNumberOfFrames = 4;
    secondRecording.checkAgainstRecorder = NO;
    
    __block XCTestExpectation *startRecordingExpectation = [self expectationWithDescription:@"start recording"];
    [self.vcr recordWithCompletionBlock:^{
        [startRecordingExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    [self recordingTaskForHTTPBinWithExpectedRecording:firstRecording taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        //        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
    
    [self recordingTaskForHTTPBinWithExpectedRecording:secondRecording taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        //        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 2);
    }];
    
    __block XCTestExpectation *ejectExpectation = [self expectationWithDescription:@"eject"];
    XCTAssertTrue([self.vcr eject:YES completionHandler:^(BOOL result, NSString *filePath) {
        [ejectExpectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    XCTAssertTrue([BKRFilePathHelper filePathExists:self.testRecordingFilePath]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedRecordings:@[firstRecording, secondRecording]];
}

- (void)testRecordingTwoConsecutiveGETRequestsWithSameRequestURLAndDifferentResponses {
    BKRExpectedRecording *firstRecording = [BKRExpectedRecording recording];
    firstRecording.URLString = @"https://pubsub.pubnub.com/time/0";
    firstRecording.responseStatusCode = 200;
    firstRecording.expectedSceneNumber = 0;
    firstRecording.expectedNumberOfFrames = 4;
    firstRecording.checkAgainstRecorder = NO;
    
    BKRExpectedRecording *secondRecording = [BKRExpectedRecording recording];
    secondRecording.URLString = firstRecording.URLString;
    secondRecording.responseStatusCode = 200;
    secondRecording.expectedSceneNumber = 1;
    secondRecording.expectedNumberOfFrames = 4;
    secondRecording.checkAgainstRecorder = NO;
    
    __block XCTestExpectation *startRecordingExpectation = [self expectationWithDescription:@"start recording"];
    [self.vcr recordWithCompletionBlock:^{
        [startRecordingExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    __block NSNumber *firstTimetoken = nil;
    [self recordingTaskWithExpectedRecording:firstRecording taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        // ensure that result from network is as expected
        XCTAssertNotNil(dataArray);
        firstTimetoken = dataArray.firstObject;
        XCTAssertNotNil(firstTimetoken);
        XCTAssertTrue([firstTimetoken isKindOfClass:[NSNumber class]]);
        NSTimeInterval firstTimeTokenAsUnix = [self unixTimestampForPubNubTimetoken:firstTimetoken];
        NSTimeInterval currentUnixTimestamp = [[NSDate date] timeIntervalSince1970];
        XCTAssertEqualWithAccuracy(firstTimeTokenAsUnix, currentUnixTimestamp, 5);
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        //        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
    
    [self recordingTaskWithExpectedRecording:secondRecording taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        // ensure that result from network is as expected
        XCTAssertNotNil(dataArray);
        NSNumber *secondTimetoken = dataArray.firstObject;
        XCTAssertNotNil(secondTimetoken);
        XCTAssertTrue([secondTimetoken isKindOfClass:[NSNumber class]]);
        NSTimeInterval secondTimeTokenAsUnix = [self unixTimestampForPubNubTimetoken:secondTimetoken];
        NSTimeInterval currentUnixTimestamp = [[NSDate date] timeIntervalSince1970];
        XCTAssertEqualWithAccuracy(secondTimeTokenAsUnix, currentUnixTimestamp, 5);
        // also make sure that the two time tokens returned are different
        XCTAssertNotEqualObjects(firstTimetoken, secondTimetoken);
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        //        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 2);
    }];
    
    __block XCTestExpectation *ejectExpectation = [self expectationWithDescription:@"eject"];
    XCTAssertTrue([self.vcr eject:YES completionHandler:^(BOOL result, NSString *filePath) {
        [ejectExpectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    XCTAssertTrue([BKRFilePathHelper filePathExists:self.testRecordingFilePath]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedRecordings:@[firstRecording, secondRecording]];
}

@end
