//
//  BKRRecordingVCRTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 2/11/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRRecordableVCR.h>
#import <BeKindRewind/BKRRecordableCassette.h>
#import <BeKindRewind/BKRNSURLSessionSwizzling.h>
#import <BeKindRewind/BKRFilePathHelper.h>
#import <BeKindRewind/NSURLSessionTask+BKRAdditions.h>
#import <BeKindRewind/NSURLSessionTask+BKRTestAdditions.h>
#import "BKRBaseTestCase.h"
#import "XCTestCase+BKRAdditions.h"

@interface BKRRecordingVCRTestCase : BKRBaseTestCase
@property (nonatomic, copy) NSString *testRecordingFilePath;
@property (nonatomic, copy) BKRBeginRecordingTaskBlock beginRecordingBlock;
@property (nonatomic, copy) BKREndRecordingTaskBlock endRecordingBlock;
@property (nonatomic, strong) BKRRecordableVCR *vcr;
@end

@implementation BKRRecordingVCRTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [BKRNSURLSessionSwizzling swizzleForRecording];
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
    
    XCTAssertTrue([self.vcr insert:self.testRecordingFilePath]);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self.vcr reset];
//    NSError *testResultRemovalError = nil;
//    BOOL removeTestResults = [[NSFileManager defaultManager] removeItemAtPath:self.testRecordingFilePath error:&testResultRemovalError];
//    XCTAssertTrue(removeTestResults);
//    XCTAssertNil(testResultRemovalError, @"Couldn't remove test results: %@", testResultRemovalError.localizedDescription);
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
    [self.vcr record];
//    BKRWeakify(self);
    [self recordingTaskForHTTPBinWithExpectedRecording:expectedRecording taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        
    }];
    
    XCTAssertTrue([self.vcr eject:YES]);
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
    recording.expectedErrorUserInfo = @{
                                        NSURLErrorFailingURLErrorKey: [NSURL URLWithString:recording.URLString],
                                        NSURLErrorFailingURLStringErrorKey: recording.URLString,
                                        NSLocalizedDescriptionKey: @"cancelled"
                                        };
    [self.vcr record];
    [self recordingTaskForHTTPBinWithExpectedRecording:recording taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
    }];
    
    XCTAssertTrue([self.vcr eject:YES]);
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
    recording.sentJSON = @{
                           @"foo": @"bar"
                           };
    [self.vcr record];
    [self recordingTaskForHTTPBinWithExpectedRecording:recording taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
    }];
    XCTAssertTrue([self.vcr eject:YES]);
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
    
    BKRExpectedRecording *secondRecording = [BKRExpectedRecording recording];
    secondRecording.URLString = @"https://httpbin.org/get?test=test2";
    secondRecording.receivedJSON = @{
                                     @"test": @"test2"
                                     };
    secondRecording.responseStatusCode = 200;
    secondRecording.expectedSceneNumber = 1;
    secondRecording.expectedNumberOfFrames = 4;
    
    [self.vcr record];
    [self recordingTaskForHTTPBinWithExpectedRecording:firstRecording taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
//        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 1);
    }];
    
    [self recordingTaskForHTTPBinWithExpectedRecording:secondRecording taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
//        XCTAssertEqual([BKRRecorder sharedInstance].allScenes.count, 2);
    }];
    
    XCTAssertTrue([self.vcr eject:YES]);
    XCTAssertTrue([BKRFilePathHelper filePathExists:self.testRecordingFilePath]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedRecordings:@[firstRecording, secondRecording]];
}

- (void)testRecordingTwoConsecutiveGETRequestsWithSameRequestURLAndDifferentResponses {
    BKRExpectedRecording *firstRecording = [BKRExpectedRecording recording];
    firstRecording.URLString = @"https://pubsub.pubnub.com/time/0";
    firstRecording.responseStatusCode = 200;
    firstRecording.expectedSceneNumber = 0;
    firstRecording.expectedNumberOfFrames = 4;
    
    BKRExpectedRecording *secondRecording = [BKRExpectedRecording recording];
    secondRecording.URLString = firstRecording.URLString;
    secondRecording.responseStatusCode = 200;
    secondRecording.expectedSceneNumber = 1;
    secondRecording.expectedNumberOfFrames = 4;
    
    [self.vcr record];
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
    
    XCTAssertTrue([self.vcr eject:YES]);
    XCTAssertTrue([BKRFilePathHelper filePathExists:self.testRecordingFilePath]);
    [self assertCassettePath:self.testRecordingFilePath matchesExpectedRecordings:@[firstRecording, secondRecording]];
}

@end