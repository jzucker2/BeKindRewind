//
//  XCTestCase+BKRHelpers.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 2/16/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRPlayer.h>
#import <BeKindRewind/BKRRecorder.h>
#import <BeKindRewind/NSURLSessionTask+BKRAdditions.h>
#import <BeKindRewind/NSURLSessionTask+BKRTestAdditions.h>
#import <BeKindRewind/BKRScene.h>
#import <BeKindRewind/BKRFrame.h>
#import <BeKindRewind/BKRCassette.h>
#import "XCTestCase+BKRHelpers.h"

@implementation BKRTestExpectedResult

- (instancetype)init {
    self = [super init];
    if (self) {
        _shouldCancel = NO;
        _expectedNumberOfFrames = 0;
        _expectedSceneNumber = 0;
        _responseCode = -1;
        _taskUniqueIdentifier = [NSUUID UUID].UUIDString;
    }
    return self;
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
        if (expectedResult.shouldCancel) {
            XCTAssertNotNil(error);
            XCTAssertEqual(expectedResult.errorCode, error.code);
            XCTAssertEqualObjects(expectedResult.errorDomain, error.domain);
            XCTAssertEqualObjects(expectedResult.errorUserInfo, error.userInfo);
        } else {
            XCTAssertNil(error);
            XCTAssertNotNil(data);
            XCTAssertNotNil(response);
            XCTAssertEqual(expectedResult.responseCode, [(NSHTTPURLResponse *)response statusCode]);
        }
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
            XCTAssertEqual(executingTask.state, NSURLSessionTaskStateCompleted);
        }
        XCTAssertNotNil(executingTask.originalRequest);
        XCTAssertNotNil(executingTask.currentRequest);
        if (timeoutAssertions) {
            timeoutAssertions(executingTask, error);
        }
    }];
}

- (void)BKRTest_executeNetworkCallsForExpectedResults:(NSArray<BKRTestExpectedResult *> *)expectedResults withTaskCompletionAssertions:(BKRTestNetworkCompletionHandler)networkCompletionAssertions taskTimeoutHandler:(BKRTestNetworkTimeoutCompletionHandler)timeoutAssertions {
    for (NSInteger i=0; i < expectedResults.count; i++) {
        BKRTestExpectedResult *expectedResult = expectedResults[i];
        [self BKRTest_executeNetworkCallWithExpectedResult:expectedResult withTaskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
            if (networkCompletionAssertions) {
                networkCompletionAssertions(task, data, response, error);
            }
        } taskTimeoutHandler:^(NSURLSessionTask *task, NSError *error) {
            XCTAssertEqual(expectedResult.expectedSceneNumber, i);
            if (timeoutAssertions) {
                timeoutAssertions(task, error);
            }
        }];
    }
}

- (void)BKRTest_executeHTTPBinNetworkCallWithExpectedResult:(BKRTestExpectedResult *)expectedResult withTaskCompletionAssertions:(BKRTestNetworkCompletionHandler)networkCompletionAssertions taskTimeoutHandler:(BKRTestNetworkTimeoutCompletionHandler)timeoutAssertions {
    [self BKRTest_executeNetworkCallWithExpectedResult:expectedResult withTaskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        if (expectedResult.shouldCancel) {
            
        } else {
            NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if ([expectedResult.HTTPMethod isEqualToString:@"POST"]) {
                NSDictionary *formDict = dataDict[@"form"];
                // for this service, need to fish out the data sent
                NSArray *formKeys = formDict.allKeys;
                NSString *rawReceivedDataString = formKeys.firstObject;
                NSDictionary *receivedDataDictionary = [NSJSONSerialization JSONObjectWithData:[rawReceivedDataString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                // ensure that result from network is as expected
                XCTAssertEqualObjects(expectedResult.HTTPBodyJSON, receivedDataDictionary);
            } else {
                XCTAssertEqualObjects(dataDict[@"args"], expectedResult.receivedJSON);
            }
        }
        if (networkCompletionAssertions) {
            networkCompletionAssertions(task, data, response, error);
        }
    } taskTimeoutHandler:^(NSURLSessionTask *task, NSError *error) {
        if (timeoutAssertions) {
            timeoutAssertions(task, error);
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

- (BKRCassette *)cassetteFromExpectedResults:(NSArray<BKRTestExpectedResult *> *)expectedResults {
    NSDate *expectedCassetteDictCreationDate = [NSDate date];
    NSMutableArray *expectedResultSceneDicts = [NSMutableArray array];
    for (BKRTestExpectedResult *expectedResult in expectedResults) {
        NSMutableArray *framesArray = [NSMutableArray array];
        NSMutableDictionary *expectedOriginalRequestDict = [self standardRequestDictionary];
        expectedOriginalRequestDict[@"URL"] = expectedResult.URLString;
        expectedOriginalRequestDict[@"uniqueIdentifier"] = expectedResult.taskUniqueIdentifier;
//        if (expectedResult.shouldCompareRequestHeaderFields) {
//            if (expectedResult.originalRequestAllHTTPHeaderFields) {
//                expectedOriginalRequestDict[@"allHTTPHeaderFields"] = expectedPlistBuilder.originalRequestAllHTTPHeaderFields;
//            }
        }
//        if (expectedResult.HTTPMethod) {
//            expectedOriginalRequestDict[@"HTTPMethod"] = expectedResult.HTTPMethod;
//        }
//        [framesArray addObject:expectedOriginalRequestDict];
    
//        if (expectedResult.hasCurrentRequest) {
//            NSMutableDictionary *expectedCurrentRequestDict = [self standardRequestDictionary];
//            expectedCurrentRequestDict[@"URL"] = expectedPlistBuilder.URLString;
//            expectedCurrentRequestDict[@"uniqueIdentifier"] = expectedPlistBuilder.taskUniqueIdentifier;
//            if (
//                (expectedPlistBuilder.currentRequestAllHTTPHeaderFields) &&
//                expectedPlistBuilder.shouldCompareRequestHeaderFields
//                ) {
//                expectedCurrentRequestDict[@"allHTTPHeaderFields"] = expectedPlistBuilder.currentRequestAllHTTPHeaderFields;
//            }
//            if (expectedPlistBuilder.HTTPMethod) {
//                expectedCurrentRequestDict[@"HTTPMethod"] = expectedPlistBuilder.HTTPMethod;
//            }
//            [framesArray addObject:expectedCurrentRequestDict];
//        }
        
//        if (expectedPlistBuilder.hasResponse) {
//            NSMutableDictionary *expectedResponseDict = [self standardResponseDictionary];
//            expectedResponseDict[@"URL"] = expectedPlistBuilder.URLString;
//            expectedResponseDict[@"uniqueIdentifier"] = expectedPlistBuilder.taskUniqueIdentifier;
//            expectedResponseDict[@"allHeaderFields"] = expectedPlistBuilder.responseAllHeaderFields;
//            [framesArray addObject:expectedResponseDict];
//        }
//        
//        if (
//            expectedPlistBuilder.receivedJSON ||
//            expectedPlistBuilder.receivedData
//            ) {
//            NSMutableDictionary *expectedDataDict = [self standardDataDictionary];
//            expectedDataDict[@"uniqueIdentifier"] = expectedPlistBuilder.taskUniqueIdentifier;
//            if (expectedPlistBuilder.receivedJSON) {
//                expectedDataDict[@"data"] = [NSJSONSerialization dataWithJSONObject:expectedPlistBuilder.receivedJSON options:kNilOptions error:nil];
//            } else {
//                expectedDataDict[@"data"] = expectedPlistBuilder.receivedData;
//            }
//            [framesArray addObject:expectedDataDict];
//        }
//        
//        if (expectedPlistBuilder.errorCode && expectedPlistBuilder.errorDomain) {
//            NSMutableDictionary *expectedErrorDict = [self standardErrorDictionary];
//            expectedErrorDict[@"code"] = @(expectedPlistBuilder.errorCode);
//            expectedErrorDict[@"domain"] = expectedPlistBuilder.errorDomain;
//            if (expectedPlistBuilder.errorUserInfo) {
//                expectedErrorDict[@"userInfo"] = expectedPlistBuilder.errorUserInfo;
//            }
//            [framesArray addObject:expectedErrorDict];
//        }
//        
//        NSDictionary *sceneDict = @{
//                                    @"uniqueIdentifier": expectedPlistBuilder.taskUniqueIdentifier,
//                                    @"frames": framesArray.copy
//                                    };
//        [expectedPlistSceneDicts addObject:sceneDict];
//    }
    
//    return [self expectedCassetteDictionaryWithCreationDate:expectedCassetteDictCreationDate sceneDictionaries:expectedPlistSceneDicts];
    return nil;
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
    expectedResult.expectedNumberOfFrames = 2;
    expectedResult.expectedSceneNumber = 0;
    expectedResult.errorDomain = NSURLErrorDomain;
    expectedResult.errorUserInfo = @{
                                     NSURLErrorFailingURLErrorKey: [NSURL URLWithString:expectedResult.URLString],
                                     NSURLErrorFailingURLStringErrorKey: expectedResult.URLString,
                                     NSLocalizedDescriptionKey: @"cancelled"
                                     };
    return expectedResult;
}

- (BKRTestExpectedResult *)HTTPBinGetRequestWithQueryString:(NSString *)queryString {
    NSString *finalQueryItemString = nil;
    NSMutableDictionary *argsDict = nil;
    if (queryString) {
        finalQueryItemString = [@"?" stringByAppendingString:queryString];
        NSURLComponents *components = [NSURLComponents componentsWithString:finalQueryItemString];
        NSArray<NSURLQueryItem *> *queryItems = [components queryItems];
        argsDict = [NSMutableDictionary dictionary];
        for (NSURLQueryItem *item in queryItems) {
            argsDict[item.name] = item.value;
        }
    }
    BKRTestExpectedResult *expectedResult = [BKRTestExpectedResult result];
    expectedResult.URLString = [NSString stringWithFormat:@"https://httpbin.org/get%@", (finalQueryItemString ? finalQueryItemString : @"")];
    expectedResult.responseCode = 200;
    expectedResult.expectedNumberOfFrames = 4;
    expectedResult.receivedJSON = argsDict.copy;
    return expectedResult;
}

- (BKRTestExpectedResult *)HTTPBinPostRequest {
    BKRTestExpectedResult *result = [BKRTestExpectedResult result];
    result.URLString = @"https://httpbin.org/post";
    result.HTTPMethod = @"POST";
    result.HTTPBodyJSON = @{
                            @"foo": @"bar"
                            };
    result.responseCode = 200;
    result.expectedSceneNumber = 0;
    result.expectedNumberOfFrames = 4;
    return result;
}

@end
