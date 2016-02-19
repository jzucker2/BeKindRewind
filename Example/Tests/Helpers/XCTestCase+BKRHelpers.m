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
#import <BeKindRewind/BKRPlayheadMatcher.h>
#import <BeKindRewind/BKRScene.h>
#import <BeKindRewind/BKRFrame.h>
#import <BeKindRewind/BKRCassette.h>
#import <BeKindRewind/BKRDataFrame.h>
#import <BeKindRewind/BKRErrorFrame.h>
#import <BeKindRewind/BKRRequestFrame.h>
#import <BeKindRewind/BKRResponseFrame.h>
#import <BeKindRewind/BKRCassette+Playable.h>
#import <BeKindRewind/BKRFilePathHelper.h>
#import "XCTestCase+BKRHelpers.h"

static NSString * const kBKRTestHTTPBinResponseDateStringValue = @"Thu, 18 Feb 2016 18:18:46 GMT";

@implementation BKRTestExpectedResult

- (instancetype)init {
    self = [super init];
    if (self) {
        _shouldCancel = NO;
        _expectedNumberOfFrames = 0;
        _expectedSceneNumber = 0;
        _responseCode = -1;
        _errorCode = 1;
        _hasCurrentRequest = NO;
        _taskUniqueIdentifier = [NSUUID UUID].UUIDString;
        _shouldCompareCurrentRequestHTTPHeaderFields = NO;
        _isRecording = NO;
        _automaticallyAssignSceneNumberForAssertion = YES;
    }
    return self;
}

+ (instancetype)result {
    return [[self alloc] init];
}

- (void)setResponseCode:(NSInteger)responseCode {
    _responseCode = responseCode;
    if (_responseCode >= 0) {
        _hasResponse = YES;
    } else {
        _hasResponse = NO;
    }
}

- (BOOL)hasError {
    return (
            (self.errorCode < 0) &&
            (self.errorDomain.length)
            );
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

- (void)setCurrentRequestAllHTTPHeaderFields:(NSDictionary *)currentRequestAllHTTPHeaderFields {
    _currentRequestAllHTTPHeaderFields = currentRequestAllHTTPHeaderFields;
    if (_currentRequestAllHTTPHeaderFields) {
        self.hasCurrentRequest = YES;
    } else {
        self.hasCurrentRequest = NO;
    }
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
    __block NSData *receivedData = nil;
    __block NSURLResponse *receivedResponse = nil;
    __block NSError *receivedError = nil;
    __block NSURLSessionTask *executingTask = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        receivedData = data;
        receivedResponse = response;
        receivedError = error;
        if (expectedResult.shouldCancel) {
            XCTAssertNotNil(error);
            XCTAssertEqual(expectedResult.errorCode, error.code);
            XCTAssertEqualObjects(expectedResult.errorDomain, error.domain);
            XCTAssertEqualObjects(expectedResult.errorUserInfo, error.userInfo);
        } else {
            XCTAssertNil(error);
            XCTAssertNotNil(data);
            XCTAssertNotNil(response);
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse *)response;
                XCTAssertEqual(expectedResult.responseCode, castedResponse.statusCode);
            }
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
        if (expectedResult.hasCurrentRequest) {
            XCTAssertNotNil(executingTask.currentRequest);
            
        }
        
        BKRTestSceneAssertionHandler sceneAssertions = ^void (BKRScene *scene) {
            [self _assertRequestFrame:scene.originalRequest withRequest:executingTask.originalRequest andIgnoreHeaderFields:YES];
            if (expectedResult.hasCurrentRequest) {
                // when we are playing, OHHTTPStubs does not mock adjusting the currentRequest to have different headers like a server would with a live NSURLSessionTask
                [self _assertRequestFrame:scene.currentRequest withRequest:executingTask.currentRequest andIgnoreHeaderFields:!expectedResult.isRecording];
            }
            if (receivedResponse) {
                [self _assertResponseFrame:scene.allResponseFrames.firstObject withResponse:receivedResponse];
            }
            if (
                receivedData &&
                !expectedResult.shouldCancel
                ) {
                [self _assertDataFrame:scene.allDataFrames.firstObject withData:receivedData];
            }
            if (receivedError) {
                [self _assertErrorFrame:scene.allErrorFrames.firstObject withError:receivedError];
            }
            [self assertFramesOrderForScene:scene];
        };
        
        if (timeoutAssertions) {
            timeoutAssertions(executingTask, error, sceneAssertions);
        }
    }];
}

- (void)_assertHTTPBinExpectedResult:(BKRTestExpectedResult *)expectedResult withActualResponseHeaderFields:(NSDictionary *)actualResponseHeaderFields {
    XCTAssertEqual(expectedResult.responseAllHeaderFields.count, actualResponseHeaderFields.count);
    NSArray *actualResponseKeysArray = actualResponseHeaderFields.allKeys;
    for (NSInteger i=0; i<actualResponseHeaderFields.count; i++) {
        NSString *actualResponseKey = actualResponseKeysArray[i];
        XCTAssertNotNil(expectedResult.responseAllHeaderFields[actualResponseKey]);
        if ([actualResponseKey isEqualToString:@"Date"]) {
            if (expectedResult.isRecording) {
                XCTAssertNotEqualObjects(actualResponseHeaderFields[actualResponseKey], expectedResult.responseAllHeaderFields[actualResponseKey]);
                XCTAssertNotEqualObjects(actualResponseHeaderFields[actualResponseKey], kBKRTestHTTPBinResponseDateStringValue);
            } else {
                XCTAssertEqualObjects(actualResponseHeaderFields[actualResponseKey], expectedResult.responseAllHeaderFields[actualResponseKey]);
                XCTAssertEqualObjects(actualResponseHeaderFields[actualResponseKey], kBKRTestHTTPBinResponseDateStringValue);
            }
        } else if ([actualResponseKey isEqualToString:@"Content-Length"]) {
            XCTAssertEqualWithAccuracy([actualResponseHeaderFields[actualResponseKey] integerValue], [expectedResult.responseAllHeaderFields[actualResponseKey] integerValue], 5);
        } else {
            XCTAssertEqualObjects(actualResponseHeaderFields[actualResponseKey], expectedResult.responseAllHeaderFields[actualResponseKey]);
        }
    }
}

- (void)BKRTest_executeNetworkCallsForExpectedResults:(NSArray<BKRTestExpectedResult *> *)expectedResults withTaskCompletionAssertions:(BKRTestBatchNetworkCompletionHandler)networkCompletionAssertions taskTimeoutHandler:(BKRTestBatchNetworkTimeoutCompletionHandler)timeoutAssertions {
    for (NSInteger i=0; i < expectedResults.count; i++) {
        BKRTestExpectedResult *expectedResult = expectedResults[i];
        if (expectedResult.automaticallyAssignSceneNumberForAssertion) {
            expectedResult.expectedSceneNumber = i;
        }
        [self BKRTest_executeNetworkCallWithExpectedResult:expectedResult withTaskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
            if (networkCompletionAssertions) {
                networkCompletionAssertions(expectedResult, task, data, response, error);
            }
        } taskTimeoutHandler:^(NSURLSessionTask *task, NSError *error, BKRTestSceneAssertionHandler sceneAssertions) {
            XCTAssertEqual(expectedResult.expectedSceneNumber, i);
            BKRTestBatchSceneAssertionHandler batchSceneAssertions = ^void (NSArray<BKRScene *> *scenes) {
                if (scenes[i]) {
                    sceneAssertions(scenes[i]);
                }
            };
            if (timeoutAssertions) {
                timeoutAssertions(expectedResult, task, error, batchSceneAssertions);
            }
        }];
    }
}

- (void)BKRTest_executeHTTPBinNetworkCallsForExpectedResults:(NSArray<BKRTestExpectedResult *> *)expectedResults withTaskCompletionAssertions:(BKRTestBatchNetworkCompletionHandler)networkCompletionAssertions taskTimeoutHandler:(BKRTestBatchNetworkTimeoutCompletionHandler)timeoutAssertions {
    [self BKRTest_executeNetworkCallsForExpectedResults:expectedResults withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        if (result.shouldCancel) {
            
        } else {
            [self _assertHTTPBinExpectedResult:result withActualResponseHeaderFields:[(NSHTTPURLResponse *)response allHeaderFields]];
            NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if ([result.HTTPMethod isEqualToString:@"POST"]) {
                NSDictionary *formDict = dataDict[@"form"];
                // for this service, need to fish out the data sent
                NSArray *formKeys = formDict.allKeys;
                NSString *rawReceivedDataString = formKeys.firstObject;
                NSDictionary *receivedDataDictionary = [NSJSONSerialization JSONObjectWithData:[rawReceivedDataString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                // ensure that result from network is as expected
                XCTAssertEqualObjects(result.HTTPBodyJSON, receivedDataDictionary);
            } else {
                XCTAssertEqualObjects(dataDict[@"args"], result.receivedJSON[@"args"]);
                XCTAssertEqualObjects(dataDict[@"url"], result.receivedJSON[@"url"]);
                XCTAssertNotNil(dataDict[@"headers"]);
                XCTAssertNotNil(dataDict[@"origin"]);
            }
        }
        if (networkCompletionAssertions) {
            networkCompletionAssertions(result, task, data, response, error);
        }
    } taskTimeoutHandler:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        if (timeoutAssertions) {
            timeoutAssertions(result, task, error, batchSceneAssertions);
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

- (void)setPlayer:(BKRPlayer *)player withExpectationToEnabled:(BOOL)enabled {
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

- (BKRPlayer *)playerWithExpectedResults:(NSArray<BKRTestExpectedResult *> *)expectedResults {
    BKRCassette *cassette = [self cassetteFromExpectedResults:expectedResults];
    NSArray<BKRScene *> *scenes = cassette.allScenes.copy;
    XCTAssertEqual(scenes.count, expectedResults.count, @"testCassette should have one valid scene right now");
    // assert on scene creation in cassette
    for (NSInteger i=0; i<expectedResults.count; i++) {
        BKRTestExpectedResult *result = [expectedResults objectAtIndex:i];
        BKRScene *scene = [scenes objectAtIndex:i];
        XCTAssertEqual(result.expectedNumberOfFrames, scene.allFrames.count);
        
    }
    BKRPlayer *player = [BKRPlayer playerWithMatcherClass:[BKRPlayheadMatcher class]];
    player.currentCassette = cassette;
    return player;
}

- (BKRCassette *)cassetteFromExpectedResults:(NSArray<BKRTestExpectedResult *> *)expectedResults {
    NSDate *expectedCassetteDictCreationDate = [NSDate date];
    NSMutableArray<NSDictionary *> *expectedResultSceneDicts = [NSMutableArray array];
    for (BKRTestExpectedResult *result in expectedResults) {
        NSMutableArray<NSDictionary *> *framesArray = [NSMutableArray array];
        NSMutableDictionary *expectedOriginalRequestDict = [self standardRequestDictionary];
        expectedOriginalRequestDict[@"URL"] = result.URLString;
        expectedOriginalRequestDict[@"uniqueIdentifier"] = result.taskUniqueIdentifier;
        if (result.HTTPMethod) {
            expectedOriginalRequestDict[@"HTTPMethod"] = result.HTTPMethod;
        }
        if (result.HTTPBody) {
            expectedOriginalRequestDict[@"HTTPBody"] = result.HTTPBody;
        }
        NSMutableDictionary *expectedCurrentRequestDict = nil;
        if (result.hasCurrentRequest) {
            expectedCurrentRequestDict = expectedOriginalRequestDict.mutableCopy;
            if (
                result.currentRequestAllHTTPHeaderFields &&
                result.shouldCompareCurrentRequestHTTPHeaderFields
                ) {
                expectedCurrentRequestDict[@"allHTTPHeaderFields"] = result.currentRequestAllHTTPHeaderFields;
            }
        }
        if (result.originalRequestAllHTTPHeaderFields) {
            expectedOriginalRequestDict[@"allHTTPHeaderFields"] = result.originalRequestAllHTTPHeaderFields;
        }
        [framesArray addObject:expectedOriginalRequestDict.copy];
        
        if (expectedCurrentRequestDict) {
            if (
                result.currentRequestAllHTTPHeaderFields &&
                result.shouldCompareCurrentRequestHTTPHeaderFields
                ) {
                expectedCurrentRequestDict[@"allHTTPHeaderFields"] = result.currentRequestAllHTTPHeaderFields;
            }
            [framesArray addObject:expectedCurrentRequestDict.copy];
        }
        if (result.hasResponse) {
            NSMutableDictionary *expectedResponseDict = [self standardResponseDictionary];
            expectedResponseDict[@"URL"] = result.URLString;
            expectedResponseDict[@"uniqueIdentifier"] = result.taskUniqueIdentifier;
            expectedResponseDict[@"allHeaderFields"] = result.responseAllHeaderFields;
            [framesArray addObject:expectedResponseDict.copy];
        }
        if (result.receivedData) {
            NSMutableDictionary *expectedDataDict = [self standardDataDictionary];
            expectedDataDict[@"uniqueIdentifier"] = result.taskUniqueIdentifier;
            expectedDataDict[@"data"] = result.receivedData;
            [framesArray addObject:expectedDataDict.copy];
        }
        if (result.hasError) {
            NSMutableDictionary *expectedErrorDict = [self standardErrorDictionary];
            expectedErrorDict[@"code"] = @(result.errorCode);
            expectedErrorDict[@"domain"] = result.errorDomain;
            if (result.errorUserInfo) {
                NSMutableDictionary *adjustedUserInfo = result.errorUserInfo.mutableCopy;
                if (result.errorUserInfo[NSURLErrorFailingURLErrorKey]) {
                    NSURL *expectedErrorURLValue = result.errorUserInfo[NSURLErrorFailingURLErrorKey];
                    adjustedUserInfo[NSURLErrorFailingURLErrorKey] = expectedErrorURLValue.absoluteString;
                }
                expectedErrorDict[@"userInfo"] = adjustedUserInfo.copy;
            }
            [framesArray addObject:expectedErrorDict.copy];
        }
        NSDictionary *sceneDict = @{
                                    @"uniqueIdentifier": result.taskUniqueIdentifier,
                                    @"frames": framesArray.copy
                                    };
        [expectedResultSceneDicts addObject:sceneDict];
    }
    NSDictionary *cassetteDictionary = @{
                                         @"creationDate": expectedCassetteDictCreationDate,
                                         @"scenes": expectedResultSceneDicts.copy
                                         };
    return [BKRCassette cassetteFromDictionary:cassetteDictionary];
}

- (void)assertFramesOrderForScene:(BKRScene *)scene {
    NSDate *lastDate = [NSDate dateWithTimeIntervalSince1970:0];
    for (BKRFrame *frame in scene.allFrames) {
        // can't just assert that creation dates are in order, in case they have the same creation date for whatever reason (likely a result of mocking)
        // so just assert that they are in increasing order or equal (not in decreasing order)
        XCTAssertNotEqual([lastDate compare:frame.creationDate], NSOrderedDescending);
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

- (NSDictionary *)_HTTPBinCurrentRequestAllHTTPHeaderFields {
    return @{
             @"Accept": @"*/*",
             @"Accept-Encoding": @"gzip, deflate",
             @"Accept-Language": @"en-us"
             };
}

- (NSDictionary *)_HTTPBinResponseAllHeaderFieldsWithContentLength:(NSString *)contentLengthString {
    return @{
             @"Access-Control-Allow-Origin": @"*",
             @"Content-Length": contentLengthString,
             @"Content-Type": @"application/json",
             @"Date": kBKRTestHTTPBinResponseDateStringValue,
             @"Server": @"nginx",
             @"access-control-allow-credentials": @"true"
             };
}

#pragma mark - HTTPBin helpers

- (BKRTestExpectedResult *)HTTPBinCancelledRequestWithRecording:(BOOL)isRecording {
    BKRTestExpectedResult *expectedResult = [BKRTestExpectedResult result];
    expectedResult.isRecording = isRecording;
    expectedResult.URLString = @"https://httpbin.org/delay/10";
    expectedResult.shouldCancel = YES;
    expectedResult.hasCurrentRequest = NO;
    expectedResult.errorCode = -999;
    expectedResult.expectedNumberOfFrames = 2;
//    expectedResult.currentRequestAllHTTPHeaderFields = [self _HTTPBinCurrentRequestAllHTTPHeaderFields];
    expectedResult.expectedSceneNumber = 0;
    expectedResult.errorDomain = NSURLErrorDomain;
    expectedResult.errorUserInfo = @{
                                     NSURLErrorFailingURLErrorKey: [NSURL URLWithString:expectedResult.URLString],
                                     NSURLErrorFailingURLStringErrorKey: expectedResult.URLString,
                                     NSLocalizedDescriptionKey: @"cancelled"
                                     };
    return expectedResult;
}

- (BKRTestExpectedResult *)HTTPBinGetRequestWithQueryString:(NSString *)queryString withRecording:(BOOL)isRecording {
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
    expectedResult.isRecording = isRecording;
    expectedResult.hasCurrentRequest = YES;
    expectedResult.URLString = [NSString stringWithFormat:@"https://httpbin.org/get%@", (finalQueryItemString ? finalQueryItemString : @"")];
    expectedResult.currentRequestAllHTTPHeaderFields = [self _HTTPBinCurrentRequestAllHTTPHeaderFields];
    expectedResult.responseCode = 200;
    expectedResult.responseAllHeaderFields = [self _HTTPBinResponseAllHeaderFieldsWithContentLength:@"338"];
    expectedResult.expectedNumberOfFrames = 4;
    expectedResult.receivedJSON = @{
                                    @"args": argsDict.copy,
                                    @"headers": @{
                                            @"Accept": @"*/*",
                                            @"Accept-Endcoding": @"gzip, deflate",
                                            @"Accept-Language": @"en-us",
                                            @"Host": @"httpbin.org",
                                            @"User-Agent": @"xctest (unknown version) CFNetwork/758.2.8 Darwin/15.3.0",
                                            },
                                    @"origin": @"98.210.195.88",
                                    @"url": expectedResult.URLString,
                                    };
    return expectedResult;
}

- (BKRTestExpectedResult *)HTTPBinPostRequestWithRecording:(BOOL)isRecording {
    BKRTestExpectedResult *result = [BKRTestExpectedResult result];
    result.isRecording = isRecording;
    result.hasCurrentRequest = YES;
    result.currentRequestAllHTTPHeaderFields = [self _HTTPBinCurrentRequestAllHTTPHeaderFields];
    result.URLString = @"https://httpbin.org/post";
    result.HTTPMethod = @"POST";
    result.responseAllHeaderFields = [self _HTTPBinResponseAllHeaderFieldsWithContentLength:@"496"];
    result.HTTPBodyJSON = @{
                            @"foo": @"bar"
                            };
    result.receivedJSON = @{
                            @"args": @{
                                    },
                            @"data": @"",
                            @"files": @{
                                    },
                            @"form": @{
                                    @"{\n  \"foo\" : \"bar\"\n}": @""
                                    },
                            @"headers": @{
                                    @"Accept": @"*/*",
                                    @"Accept-Encoding": @"gzip, deflate",
                                    @"Accept-Language": @"en-us",
                                    @"Host": @"httpbin.org",
                                    @"User-Agent": @"xctest (unknown version) CFNetwork/758.2.8 Darwin/15.3.0"
                                    },
                            @"json": @"<null>",
                            @"origin": @"67.180.11.233",
                            @"url": @"https://httpbin.org/post"
                            };
    result.responseCode = 200;
    result.expectedSceneNumber = 0;
    result.expectedNumberOfFrames = 4;
    return result;
}

- (void)_assertDataFrame:(BKRDataFrame *)dataFrame withData:(NSData *)data {
    XCTAssertNotNil(dataFrame);
    XCTAssertNotNil(data);
    XCTAssertNotNil(dataFrame.rawData);
    XCTAssertEqualObjects(dataFrame.rawData, data);
}

- (void)_assertResponseFrame:(BKRResponseFrame *)responseFrame withResponse:(NSURLResponse *)response {
    XCTAssertNotNil(responseFrame);
    XCTAssertNotNil(response);
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *castedDataTaskResponse = (NSHTTPURLResponse *)response;
        XCTAssertEqualObjects(responseFrame.allHeaderFields, castedDataTaskResponse.allHeaderFields);
        XCTAssertEqual(responseFrame.statusCode, castedDataTaskResponse.statusCode);
    }
}

- (void)_assertRequestFrame:(BKRRequestFrame *)requestFrame withRequest:(NSURLRequest *)request andIgnoreHeaderFields:(BOOL)shouldIgnoreHeaderFields {
    XCTAssertNotNil(requestFrame);
    XCTAssertNotNil(request);
    XCTAssertEqual(requestFrame.HTTPShouldHandleCookies, request.HTTPShouldHandleCookies);
    XCTAssertEqual(requestFrame.HTTPShouldUsePipelining, request.HTTPShouldUsePipelining);
    if (!shouldIgnoreHeaderFields) {
        XCTAssertEqualObjects(requestFrame.allHTTPHeaderFields, request.allHTTPHeaderFields);
    }
    XCTAssertEqualObjects(requestFrame.URL, request.URL);
    XCTAssertEqual(requestFrame.timeoutInterval, request.timeoutInterval);
    XCTAssertEqualObjects(requestFrame.HTTPMethod, request.HTTPMethod);
    XCTAssertEqual(requestFrame.allowsCellularAccess, request.allowsCellularAccess);
}

- (void)_assertErrorFrame:(BKRErrorFrame *)errorFrame withError:(NSError *)error {
    XCTAssertNotNil(errorFrame);
    XCTAssertNotNil(error);
    XCTAssertEqual(errorFrame.code, error.code);
    XCTAssertEqualObjects(errorFrame.domain, error.domain);
    if (errorFrame.userInfo || error.userInfo) {
        XCTAssertEqualObjects(errorFrame.userInfo, error.userInfo);
    }
}

- (void)assertCassettePath:(NSString *)cassetteFilePath matchesExpectedResults:(NSArray<BKRTestExpectedResult *> *)expectedResults {
    XCTAssertTrue([BKRFilePathHelper filePathExists:cassetteFilePath]);
    NSDictionary *cassetteDictionary = [BKRFilePathHelper dictionaryForPlistFilePath:cassetteFilePath];
    XCTAssertTrue([cassetteDictionary isKindOfClass:[NSDictionary class]]);
    XCTAssertTrue([cassetteDictionary[@"creationDate"] isKindOfClass:[NSDate class]]);
    NSArray *scenes = cassetteDictionary[@"scenes"];
    XCTAssertEqual(expectedResults.count, scenes.count);
    // if there are no expected recordings, then there are no more comparisons left
    if (!expectedResults.count) {
        return;
    }
#warning finish this!
}

#pragma mark - VCR helpers

- (void)setVCRBeginAndEndRecordingBlocks:(id<BKRVCRRecording>)vcr {
    vcr.beginRecordingBlock = ^void(NSURLSessionTask *task) {
        NSString *recordingExpectationString = [NSString stringWithFormat:@"Task: %@", task.globallyUniqueIdentifier];
        task.recordingExpectation = [self expectationWithDescription:recordingExpectationString];
    };
    
    vcr.endRecordingBlock = ^void(NSURLSessionTask *task) {
        [task.recordingExpectation fulfill];
    };
}

- (void)insertCassetteFilePath:(NSString *)cassetteFilePath intoVCR:(id<BKRVCRActions>)vcr {
    XCTAssertNotNil(cassetteFilePath);
    XCTAssertNotNil(vcr);
    __block XCTestExpectation *insertExpectation = [self expectationWithDescription:@"insert expectation"];
    XCTAssertTrue([vcr insert:cassetteFilePath completionHandler:^(BOOL result, NSString *filePath) {
        [insertExpectation fulfill];
        insertExpectation = nil;
    }]);
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)resetVCR:(id<BKRVCRActions>)vcr {
    __block XCTestExpectation *resetExpectation = [self expectationWithDescription:@"reset expectation"];
    [vcr resetWithCompletionBlock:^{
        [resetExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (BOOL)ejectCassetteFromVCR:(id<BKRVCRActions>)vcr {
    __block XCTestExpectation *ejectExpectation = [self expectationWithDescription:@"eject"];
    BOOL result = [vcr eject:YES completionHandler:^(BOOL result, NSString *filePath) {
        [ejectExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    return result;
}

- (void)playVCR:(id<BKRVCRActions>)vcr {
    __block XCTestExpectation *playExpectation = [self expectationWithDescription:@"start playing expectation"];
    [vcr playWithCompletionBlock:^{
        [playExpectation fulfill];
        playExpectation = nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)recordVCR:(id<BKRVCRActions>)vcr {
    __block XCTestExpectation *recordExpectation = [self expectationWithDescription:@"start recording expectation"];
    [vcr recordWithCompletionBlock:^{
        [recordExpectation fulfill];
        recordExpectation = nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)stopVCR:(id<BKRVCRActions>)vcr {
    __block XCTestExpectation *stopExpectation = [self expectationWithDescription:@"stop vcr expectation"];
    [vcr stopWithCompletionBlock:^{
        [stopExpectation fulfill];
        stopExpectation = nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

@end
