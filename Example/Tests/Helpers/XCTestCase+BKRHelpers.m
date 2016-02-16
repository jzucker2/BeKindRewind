//
//  XCTestCase+BKRHelpers.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 2/16/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRPlayer.h>
#import <BeKindRewind/BKRRecorder.h>
#import <BeKindRewind/NSURLSessionTask+BKRTestAdditions.h>
#import <BeKindRewind/BKRScene.h>
#import "XCTestCase+BKRHelpers.h"

@implementation BKRTestExpectedResult

- (instancetype)init {
    self = [super init];
    if (self) {
        _shouldCancel = NO;
    }
}

+ (instancetype)result {
    return [[self alloc] init];
}

- (void)setHTTPBody:(NSData *)HTTPBody {
    _HTTPBody = HTTPBody;
    _HTTPBodyJSON = [NSJSONSerialization JSONObjectWithData:HTTPBody options:NSJSONReadingAllowFragments error:nil];
}

- (void)setHTTPBodyJSON:(NSDictionary *)HTTPBodyJSON {
    _HTTPBodyJSON = HTTPBodyJSON;
    _HTTPBody = [NSJSONSerialization dataWithJSONObject:HTTPBodyJSON options:NSJSONWritingPrettyPrinted error:nil];
}

- (void)setReceivedData:(NSData *)receivedData {
    _receivedData = receivedData;
    _receivedJSON = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingAllowFragments error:nil];
}

- (void)setReceivedJSON:(NSDictionary *)receivedJSON {
    _receivedJSON = receivedJSON;
    _receivedData = [NSJSONSerialization dataWithJSONObject:receivedJSON options:NSJSONWritingPrettyPrinted error:nil];
}

@end

@implementation XCTestCase (BKRHelpers)

- (void)BKRTest_executeNetworkCallWithExpectedResult:(BKRTestExpectedResult *)expectedResult withTaskCompletionAssertions:(BKRTestNetworkCompletionHandler)networkCompletionAssertions taskTimeoutHandler:(BKRTestNetworkTimeoutCompletionHandler)timeoutAssertions {
    NSURL *requestURL = [NSURL URLWithString:expectedResult.URLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    if (expectedResult.HTTPMethod) {
        request.HTTPMethod = expectedResult.HTTPMethod;
    }
    if (expectedResult.HTTPBody) {
        request.HTTPBody = expectedResult.HTTPBody;
    }
    __block XCTestExpectation *networkExpectation = [self expectationWithDescription:@"network call expectation"];
    __block NSURLSessionTask *executingTask = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (networkCompletionAssertions) {
            networkCompletionAssertions(executingTask, data, response, error);
        }
        [networkExpectation fulfill];
        networkExpectation = nil;
    }];
    XCTAssertEqual(executingTask.state, NSURLSessionTaskStateSuspended);
    [executingTask resume];
    if (expectedResult.shouldCancel) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [executingTask cancel];
            XCTAssertNotEqual(executingTask.state, NSURLSessionTaskStateRunning);
            XCTAssertNotEqual(executingTask.state, NSURLSessionTaskStateSuspended);
        });
    }
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
        if (expectedResult.shouldCancel) {
            XCTAssertNotEqual(executingTask.state, NSURLSessionTaskStateRunning);
            XCTAssertNotEqual(executingTask.state, NSURLSessionTaskStateSuspended);
        } else {
            XCTAssertEqual(task.state, NSURLSessionTaskStateCompleted);
        }
        XCTAssertNotNil(executingTask.originalRequest);
        XCTAssertNotNil(executingTask.currentRequest);
        if (timeoutAssertions) {
            timeoutAssertions(executingTask, error);
        }
    }];
}

- (void)setRecorderToEnabledWithExpectation:(BOOL)enabled {
    __block XCTestExpectation *enableChangeExpectation = [self expectationWithDescription:@"enable expectation"];
    [[BKRRecorder sharedInstance] setEnabled:enabled withCompletionHandler:^{
        [enableChangeExpectation fulfill];
        enableChangeExpectation = nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)setPlayer:(BKRPlayer *)player toEnabledWithExpectation:(BOOL)enabled {
    __block XCTestExpectation *enableChangeExpectation = [self expectationWithDescription:@"enable expectation"];
    [player setEnabled:enabled withCompletionHandler:^{
        [enableChangeExpectation fulfill];
        enableChangeExpectation = nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)setRecorderBeginAndEndRecordingBlocks {
    [BKRRecorder sharedInstance].beginRecordingBlock = ^void(NSURLSessionTask *task) {
        NSString *recordingExpectationString = [NSString stringWithFormat:@"Task: %@", task.globallyUniqueIdentifier];
        task.recordingExpectation = [self expectationWithDescription:recordingExpectationString];
    };
    
    [BKRRecorder sharedInstance].endRecordingBlock = ^void(NSURLSessionTask *task) {
        [task.recordingExpectation fulfill];
    };
}

- (void)assertFramesOrderForScene:(BKRScene *)scene {
    NSDate *lastDate = [NSDate dateWithTimeIntervalSince1970:0];
    for (BKRFrame *frame in scene.allFrames) {
        XCTAssertEqual([lastDate compare:frame.creationDate], NSOrderedAscending);
        lastDate = frame.creationDate;
    }
}

- (NSMutableDictionary *)standardDataDictionary {
    return [@{
              @"class": @"BKRDataFrame",
              @"creationDate": [NSDate date],
              } mutableCopy];
}

- (NSMutableDictionary *)standardRequestDictionary {
    return [@{
              @"class": @"BKRRequestFrame",
              @"creationDate": [NSDate date],
              @"timeoutInterval": @(60),
              @"HTTPShouldUsePipelining": @(NO),
              @"HTTPShouldHandleCookies": @(YES),
              @"allowsCellularAccess": @(YES),
              @"HTTPMethod": @"GET"
              } mutableCopy];
}

- (NSMutableDictionary *)standardResponseDictionary {
    return [@{
              @"class": @"BKRResponseFrame",
              @"creationDate": [NSDate date],
              @"MIMEType": @"application/json",
              @"statusCode": @(200)
              } mutableCopy];
}

- (NSMutableDictionary *)standardErrorDictionary {
    return [@{
              @"class": @"BKRErrorFrame",
              @"creationDate": [NSDate date],
              } mutableCopy];
}

#pragma mark - HTTPBin helpers

- (BKRTestExpectedResult *)HTTPBinCancelledRequest {
    BKRTestExpectedResult *expectedResult = [BKRTestExpectedResult result];
    expectedResult.URLString = @"https://httpbin.org/delay/10";
    expectedResult.shouldCancel = YES;
    expectedResult.errorCode = -999;
    expectedResult.errorDomain = NSURLErrorDomain;
    expectedResult.errorUserInfo = @{
                                     NSURLErrorFailingURLErrorKey: [NSURL URLWithString:expectedResult.URLString],
                                     NSURLErrorFailingURLStringErrorKey: expectedResult.URLString,
                                     NSLocalizedDescriptionKey: @"cancelled"
                                     };
    return expectedResult;
}

- (BKRTestExpectedResult *)HTTPBinGetRequestWithArgs:(NSDictionary *)args {
    
}

- (BKRTestExpectedResult *)HTTPBinPostRequest {
    
}

@end
