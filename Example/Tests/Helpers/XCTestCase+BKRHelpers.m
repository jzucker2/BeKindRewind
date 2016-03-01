//
//  XCTestCase+BKRHelpers.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 2/16/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRPlayer.h>
#import <BeKindRewind/BKRRecorder.h>
#import <BeKindRewind/BKRPlayableVCR.h>
#import <BeKindRewind/NSURLSessionTask+BKRAdditions.h>
#import <BeKindRewind/NSURLSessionTask+BKRTestAdditions.h>
#import <BeKindRewind/BKRPlayheadMatcher.h>
#import <BeKindRewind/BKRAnyMatcher.h>
#import <BeKindRewind/BKRScene.h>
#import <BeKindRewind/BKRFrame.h>
#import <BeKindRewind/BKRCassette.h>
#import <BeKindRewind/BKRDataFrame.h>
#import <BeKindRewind/BKRErrorFrame.h>
#import <BeKindRewind/BKRRequestFrame.h>
#import <BeKindRewind/BKRResponseFrame.h>
#import <BeKindRewind/BKRConfiguration.h>
#import <BeKindRewind/BKRTestConfiguration.h>
#import <BeKindRewind/BKRCassette+Playable.h>
#import <BeKindRewind/BKRFilePathHelper.h>
#import <BeKindRewind/BKRVCR.h>
#import "XCTestCase+BKRHelpers.h"

static NSString * const kBKRTestHTTPBinResponseDateStringValue = @"Thu, 18 Feb 2016 18:18:46 GMT";

@implementation BKRTestExpectedResult

- (instancetype)init {
    self = [super init];
    if (self) {
        _shouldCancel = NO;
        _expectedNumberOfPlayingFrames = 0;
        _expectedNumberOfRecordingFrames = 0;
        _expectedSceneNumber = 0;
        _responseCode = -1;
        _isSimultaneous = NO;
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

- (NSURL *)URL {
    return [NSURL URLWithString:self.URLString];
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
    if (_HTTPBody) {
        _HTTPBodyJSON = [NSJSONSerialization JSONObjectWithData:HTTPBody options:NSJSONReadingAllowFragments error:nil];
    } else {
        _HTTPBodyJSON = nil;
    }
}

- (void)setHTTPBodyJSON:(NSDictionary *)HTTPBodyJSON {
    _HTTPBodyJSON = HTTPBodyJSON;
    if (_HTTPBodyJSON) {
        _HTTPBody = [NSJSONSerialization dataWithJSONObject:HTTPBodyJSON options:NSJSONWritingPrettyPrinted error:nil];
    } else {
        _HTTPBody = nil;
    }
}

- (void)setReceivedData:(NSData *)receivedData {
    _receivedData = receivedData;
    if (_receivedData) {
        _receivedJSON = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingAllowFragments error:nil];
    } else {
        _receivedJSON = nil;
    }
}

- (void)setReceivedJSON:(id)receivedJSON {
    _receivedJSON = receivedJSON;
    if (receivedJSON) {
        _receivedData = [NSJSONSerialization dataWithJSONObject:receivedJSON options:NSJSONWritingPrettyPrinted error:nil];
    } else {
        _receivedData = nil;
    }
}

- (void)setCurrentRequestAllHTTPHeaderFields:(NSDictionary *)currentRequestAllHTTPHeaderFields {
    _currentRequestAllHTTPHeaderFields = currentRequestAllHTTPHeaderFields;
    if (_currentRequestAllHTTPHeaderFields) {
        _hasCurrentRequest = YES;
    } else {
        _hasCurrentRequest = NO;
    }
}

@end

@implementation XCTestCase (BKRHelpers)

- (BKRConfiguration *)defaultConfiguration {
    BKRConfiguration *configuration = [BKRConfiguration defaultConfiguration];
    [self _setBeginAndEndRecordingBlocksForConfiguration:configuration];
    return configuration;
}

- (void)insertNewCassetteInRecorder {
    BKRCassette *cassette = [BKRCassette cassette];
    [BKRRecorder sharedInstance].currentCassette = cassette;
}

- (BKRPlayableVCR *)playableVCRWithPlayheadMatcher {
    return [BKRPlayableVCR defaultVCR];
}

- (BKRPlayableVCR *)playableVCRWithAnyMatcher {
    BKRConfiguration *configuration = [BKRConfiguration configurationWithMatcherClass:[BKRAnyMatcher class]];
    return [BKRPlayableVCR vcrWithConfiguration:configuration];
}

- (BKRVCR *)vcrWithPlayheadMatcherAndCassetteSavingOption:(BOOL)cassetteSavingOption {
    BKRConfiguration *configuration = [self defaultConfiguration];
    configuration.shouldSaveEmptyCassette = cassetteSavingOption;
    return [BKRVCR vcrWithConfiguration:configuration];
}

- (BKRVCR *)vcrWithMatcher:(Class<BKRRequestMatching>)matcherClass andCassetteSavingOption:(BOOL)cassetteSavingOption {
    BKRConfiguration *configuration = [self defaultConfiguration];
    configuration.shouldSaveEmptyCassette = cassetteSavingOption;
    configuration.matcherClass = matcherClass;
    return [BKRVCR vcrWithConfiguration:configuration];
}

- (void)BKRTest_executeNetworkCallWithExpectedResult:(BKRTestExpectedResult *)expectedResult withTaskCompletionAssertions:(BKRTestNetworkCompletionHandler)networkCompletionAssertions taskTimeoutHandler:(BKRTestNetworkTimeoutCompletionHandler)timeoutAssertions {
    
    NSURLSessionTask *executingTask = [self _preparedTaskForExpectedResult:expectedResult andTaskCompletionAssertions:networkCompletionAssertions];
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
            XCTAssertNotEqual(executingTask.state, NSURLSessionTaskStateRunning, @"If task is still running, then it failed to cancel as expected, this is most likely not a BeKindRewind bug but a system bug");
            XCTAssertNotEqual(executingTask.state, NSURLSessionTaskStateSuspended, @"If task is suspended, it did not properly cancel, this might be a system bug and not a BeKindRewind bug");
        } else {
            XCTAssertEqual(executingTask.state, NSURLSessionTaskStateCompleted, @"If state is not completed, that most likely means the request failed due to a bad connection");
            XCTAssertEqual(executingTask.state, NSURLSessionTaskStateCompleted);
        }
        XCTAssertNotNil(executingTask.originalRequest);
        if (expectedResult.hasCurrentRequest) {
            XCTAssertNotNil(executingTask.currentRequest);
        }
        
        BKRTestSceneAssertionHandler sceneAssertions = [self _assertionHandlerForExpectedResult:expectedResult andTask:executingTask];
        
        if (timeoutAssertions) {
            timeoutAssertions(executingTask, error, sceneAssertions);
        }
    }];
}

- (BKRTestSceneAssertionHandler)_assertionHandlerForExpectedResult:(BKRTestExpectedResult *)expectedResult andTask:(NSURLSessionTask *)task {
    BKRTestSceneAssertionHandler sceneAssertions = ^void (BKRScene *scene) {
        [self _assertRequestFrame:scene.originalRequest withRequest:task.originalRequest andIgnoreHeaderFields:YES];
        if (expectedResult.hasCurrentRequest) {
            // when we are playing, OHHTTPStubs does not mock adjusting the currentRequest to have different headers like a server would with a live NSURLSessionTask
            [self _assertRequestFrame:scene.currentRequest withRequest:task.currentRequest andIgnoreHeaderFields:!expectedResult.isRecording];
        }
        if (expectedResult.actualReceivedResponse) {
            [self _assertResponseFrame:scene.allResponseFrames.firstObject withResponse:expectedResult.actualReceivedResponse];
        }
        if (
            expectedResult.actualReceivedData &&
            !expectedResult.shouldCancel
            ) {
            [self _assertDataFrame:scene.allDataFrames.firstObject withData:expectedResult.actualReceivedData];
        }
        if (expectedResult.actualReceivedError) {
            [self _assertErrorFrame:scene.allErrorFrames.firstObject withError:expectedResult.actualReceivedError];
        }
        [self assertFramesOrderForScene:scene];
    };
    
    return sceneAssertions;
}

- (NSURLSessionTask *)_preparedTaskForExpectedResult:(BKRTestExpectedResult *)expectedResult andTaskCompletionAssertions:(BKRTestNetworkCompletionHandler)networkCompletionAssertions {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:expectedResult.URL];
    if (expectedResult.HTTPMethod) {
        request.HTTPMethod = expectedResult.HTTPMethod;
    }
    if (expectedResult.HTTPBody) {
        request.HTTPBody = expectedResult.HTTPBody;
    }
    NSString *networkExpectationString = [NSString stringWithFormat:@"network call expectation for task: %@", expectedResult.taskUniqueIdentifier];
    __block XCTestExpectation *networkExpectation = [self expectationWithDescription:networkExpectationString];
    __block NSURLSessionTask *executingTask = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        expectedResult.actualReceivedData = data;
        expectedResult.actualReceivedResponse = response;
        expectedResult.actualReceivedError = error;
        if (expectedResult.shouldCancel) {
            XCTAssertNotNil(error);
            XCTAssertEqual(expectedResult.errorCode, error.code);
            XCTAssertEqualObjects(expectedResult.errorDomain, error.domain);
            XCTAssertEqualObjects(expectedResult.errorUserInfo, error.userInfo);
        } else {
            XCTAssertNil(error);
            XCTAssertNotNil(data);
            [self _assertExpectedResult:expectedResult withData:data];
            XCTAssertNotNil(response);
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse *)response;
                XCTAssertEqual(expectedResult.responseCode, castedResponse.statusCode);
                [self _assertExpectedResult:expectedResult withActualResponseHeaderFields:castedResponse.allHeaderFields];
            }
        }
        if (networkCompletionAssertions) {
            networkCompletionAssertions(executingTask, data, response, error);
        }
        [networkExpectation fulfill];
        networkExpectation = nil;
    }];
    XCTAssertNotNil(executingTask);
    XCTAssertEqual(executingTask.state, NSURLSessionTaskStateSuspended);
    return executingTask;
}

- (void)_assertExpectedResult:(BKRTestExpectedResult *)expectedResult withData:(NSData *)data {
    NSError *JSONError = nil;
    id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&JSONError];
    XCTAssertNil(JSONError, @"Failed to convert data to JSON: %@", JSONError.localizedDescription);
    if ([expectedResult.URL.host isEqualToString:@"httpbin.org"]) {
        NSDictionary *dataDict = (NSDictionary *)JSONObject;
        XCTAssertTrue([dataDict isKindOfClass:[NSDictionary class]]);
        if ([expectedResult.HTTPMethod isEqualToString:@"POST"]) {
            NSDictionary *formDict = dataDict[@"form"];
            // for this service, need to fish out the data sent
            NSArray *formKeys = formDict.allKeys;
            NSString *rawReceivedDataString = formKeys.firstObject;
            NSDictionary *receivedDataDictionary = [NSJSONSerialization JSONObjectWithData:[rawReceivedDataString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            // ensure that result from network is as expected
            XCTAssertEqualObjects(expectedResult.HTTPBodyJSON, receivedDataDictionary);
        } else if (
                   !expectedResult.HTTPMethod ||
                   [expectedResult.HTTPMethod isEqualToString:@"GET"]
                   ) {
            XCTAssertEqualObjects(dataDict[@"args"], expectedResult.receivedJSON[@"args"]);
            XCTAssertEqualObjects(dataDict[@"url"], expectedResult.receivedJSON[@"url"]);
            XCTAssertNotNil(dataDict[@"headers"]);
            XCTAssertNotNil(dataDict[@"origin"]);
        } else {
            XCTFail(@"not prepared to handle this type of request: %@", expectedResult.HTTPMethod);
        }
    } else if ([expectedResult.URL.host isEqualToString:@"pubsub.pubnub.com"]) {
        NSArray *dataArray = (NSArray *)JSONObject;
        XCTAssertTrue([dataArray isKindOfClass:[NSArray class]]);
        // ensure that result from network is as expected
        XCTAssertNotNil(dataArray);
        NSNumber *firstTimetoken = dataArray.firstObject;
        XCTAssertNotNil(firstTimetoken);
        XCTAssertTrue([firstTimetoken isKindOfClass:[NSNumber class]]);
        if (expectedResult.isRecording) {
            NSTimeInterval firstTimeTokenAsUnix = [self _unixTimestampForPubNubTimetoken:firstTimetoken];
            NSTimeInterval currentUnixTimestamp = [[NSDate date] timeIntervalSince1970];
            XCTAssertEqualWithAccuracy(firstTimeTokenAsUnix, currentUnixTimestamp, 5);
        }
    } else {
        XCTFail(@"not prepared to handle URL: %@ for expected result: %@", expectedResult.URLString, expectedResult);
    }
}

- (void)_assertExpectedResult:(BKRTestExpectedResult *)expectedResult withActualCurrentRequestHeaderFields:(NSDictionary *)actualHeaderFields {
    XCTAssertEqual(expectedResult.currentRequestAllHTTPHeaderFields.count, actualHeaderFields.count);
    NSArray *actualResponseKeysArray = actualHeaderFields.allKeys;
    for (NSInteger i=0; i<actualHeaderFields.count; i++) {
        NSString *actualResponseKey = actualResponseKeysArray[i];
        XCTAssertNotNil(expectedResult.currentRequestAllHTTPHeaderFields[actualResponseKey]);
        if ([actualResponseKey isEqualToString:@"Content-Length"]) {
            XCTAssertEqualWithAccuracy([actualHeaderFields[actualResponseKey] integerValue], [expectedResult.currentRequestAllHTTPHeaderFields[actualResponseKey] integerValue], 5);
        } else {
            XCTAssertEqualObjects(actualHeaderFields[actualResponseKey], expectedResult.currentRequestAllHTTPHeaderFields[actualResponseKey]);
        }
    }
}

- (void)assertDefaultTestConfiguration:(BKRTestConfiguration *)configuration {
    XCTAssertNotNil(configuration);
    XCTAssertEqualObjects(configuration.currentTestCase, self);
    XCTAssertEqual(configuration.shouldSaveEmptyCassette, NO);
    XCTAssertEqual(configuration.matcherClass, [BKRPlayheadMatcher class]);
    XCTAssertNotNil(configuration.beginRecordingBlock);
    XCTAssertNotNil(configuration.endRecordingBlock);
}

- (void)_assertExpectedResult:(BKRTestExpectedResult *)expectedResult withActualResponseHeaderFields:(NSDictionary *)actualResponseHeaderFields {
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
            XCTAssertEqualWithAccuracy([actualResponseHeaderFields[actualResponseKey] integerValue], [expectedResult.responseAllHeaderFields[actualResponseKey] integerValue], 35);
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

- (void)BKRTest_executeSimultaneousNetworkCallsForExpectedResults:(NSArray<BKRTestExpectedResult *> *)expectedResults withTaskCompletionAssertions:(BKRTestBatchNetworkCompletionHandler)networkCompletionAssertions taskTimeoutHandler:(BKRTestBatchNetworkTimeoutCompletionHandler)timeoutAssertions {
//    dispatch_queue_t simultaneousTestingQueue = dispatch_queue_create("com.BKRTesting.SimultaneousQueue", DISPATCH_QUEUE_CONCURRENT);
//    BKRWeakify(self);
//    dispatch_apply(expectedResults.count, simultaneousTestingQueue, ^(size_t interation) {
//        BKRStrongify(self);
//    });
    __block BOOL isRecording = NO;
    NSMutableArray<NSURLSessionTask *> *executedTasks = [NSMutableArray array];
    for (NSInteger i=0; i <expectedResults.count; i++) {
        BKRTestExpectedResult *expectedResult = expectedResults[i];
        if (i == 0) {
            isRecording = expectedResult.isRecording;
        }
        NSURLSessionTask *task = [self _preparedTaskForExpectedResult:expectedResult andTaskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
            if (networkCompletionAssertions) {
                networkCompletionAssertions(expectedResult, task, data, response, error);
            }
        }];
        NSUInteger executedTasksCount = executedTasks.count;
        executedTasks[i] = task;
        XCTAssertEqual(executedTasks.count, ++executedTasksCount);
        [task resume];
    }
    // ensure all tasks are running (expects tasks that take a not insignificant amount of time)
    // for now, playing tasks are immediate, so this check is skipped when not recording
    // when playing time overrides are introduced, update this
    // also since, all tests are expected to only take arrays of recording or playing tasks but not
    // both, just check first expected result to determine (under previously stated assumption) that
    // all tasks are recording or playing
    // note: maybe consider using isSimultaneous (this was added after this was written)
    for (NSInteger i=0; i < expectedResults.count; i++) {
        NSURLSessionTask *checkingTask = executedTasks[i];
        XCTAssertNotNil(checkingTask);
        if (isRecording) {
            XCTAssertEqual(checkingTask.state, NSURLSessionTaskStateRunning);
        }
    }
    __block NSMutableArray<BKRScene *> *scenesToCheck = nil;
    XCTAssertNil(scenesToCheck);
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
        for (NSInteger i=0; i <expectedResults.count; i++) {
            BKRTestExpectedResult *expectedResult = expectedResults[i];
            NSURLSessionTask *executingTask = executedTasks[i];
            XCTAssertNotNil(executingTask);
            if (expectedResult.shouldCancel) {
                XCTAssertNotEqual(executingTask.state, NSURLSessionTaskStateRunning, @"If task is still running, then it failed to cancel as expected, this is most likely not a BeKindRewind bug but a system bug");
                XCTAssertNotEqual(executingTask.state, NSURLSessionTaskStateSuspended, @"If task is suspended, it did not properly cancel, this might be a system bug and not a BeKindRewind bug");
            } else {
                XCTAssertEqual(executingTask.state, NSURLSessionTaskStateCompleted, @"If state is not completed, that most likely means the request failed due to a bad connection");
                XCTAssertEqual(executingTask.state, NSURLSessionTaskStateCompleted);
            }
            XCTAssertNotNil(executingTask.originalRequest);
            if (expectedResult.hasCurrentRequest) {
                XCTAssertNotNil(executingTask.currentRequest);
                
            }
            BKRTestSceneAssertionHandler sceneAssertions = [self _assertionHandlerForExpectedResult:expectedResult andTask:executingTask];
            BKRTestBatchSceneAssertionHandler batchSceneAssertions = ^void (NSArray<BKRScene *> *scenes) {
                if (
                    !scenes ||
                    !scenes.count
                    ) {
                    NSLog(@"can't do batch scene assertions when no scenes are provided to assert on!");
                    return;
                }
                if (!scenesToCheck) {
                    scenesToCheck = scenes.mutableCopy;
                }
                XCTAssertNotNil(scenesToCheck);
                NSUInteger currentScenesToCheckCount = scenesToCheck.count;
                for (BKRScene *scene in scenes) {
                    if ([scene.originalRequest.URL.absoluteString isEqualToString:executingTask.originalRequest.URL.absoluteString]) {
                        sceneAssertions(scene);
                        [scenesToCheck removeObject:scene];
                    }
                }
                XCTAssertEqual(--currentScenesToCheckCount, scenesToCheck.count, @"After asserting a scenes, count of scenesToCheck should decrement, not %lu", (unsigned long)scenesToCheck.count);
            };
            if (timeoutAssertions) {
                timeoutAssertions(expectedResult, executingTask, error, batchSceneAssertions);
            }
        }
        // if for some reason, this array is nil, don't check this
        if (scenesToCheck) {
            XCTAssertEqual(scenesToCheck.count, 0, @"After all assertions, there shouldn't be any scenes left to check: %lu", (unsigned long)scenesToCheck.count);
        }
    }];
}

- (void)BKRTest_executeHTTPBinNetworkCallsForExpectedResults:(NSArray<BKRTestExpectedResult *> *)expectedResults simultaneously:(BOOL)simultaneously withTaskCompletionAssertions:(BKRTestBatchNetworkCompletionHandler)networkCompletionAssertions taskTimeoutHandler:(BKRTestBatchNetworkTimeoutCompletionHandler)timeoutAssertions {
    
    BKRTestBatchNetworkCompletionHandler networkCompletionHandler = ^void (BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        if (result.shouldCancel) {
            
        } else {
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
    };
    
    BKRTestBatchNetworkTimeoutCompletionHandler networkTimeoutHandler = ^void (BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions) {
        if (timeoutAssertions) {
            timeoutAssertions(result, task, error, batchSceneAssertions);
        }
    };
    
    if (simultaneously) {
        [self BKRTest_executeSimultaneousNetworkCallsForExpectedResults:expectedResults withTaskCompletionAssertions:networkCompletionHandler taskTimeoutHandler:networkTimeoutHandler];
    } else {
        [self BKRTest_executeNetworkCallsForExpectedResults:expectedResults withTaskCompletionAssertions:networkCompletionHandler taskTimeoutHandler:networkTimeoutHandler];
    }
}

- (void)BKRTest_executePNTimeTokenNetworkCallsForExpectedResults:(NSArray<BKRTestExpectedResult *> *)expectedResults withTaskCompletionAssertions:(BKRTestBatchNetworkCompletionHandler)networkCompletionAssertions taskTimeoutHandler:(BKRTestBatchNetworkTimeoutCompletionHandler)timeoutAssertions {
    __block NSMutableSet<NSNumber *> *allReceivedTimetokens = [NSMutableSet set];
    [self BKRTest_executeNetworkCallsForExpectedResults:expectedResults withTaskCompletionAssertions:^(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        if (result.shouldCancel) {
            
        } else {
            NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            // ensure that result from network is as expected
            XCTAssertNotNil(dataArray);
            NSNumber *firstTimetoken = dataArray.firstObject;
            XCTAssertNotNil(firstTimetoken);
            XCTAssertTrue([firstTimetoken isKindOfClass:[NSNumber class]]);
            XCTAssertFalse([allReceivedTimetokens containsObject:firstTimetoken], @"This time token should have never been received before: %@ but we received these: %@", firstTimetoken, allReceivedTimetokens);
            [allReceivedTimetokens addObject:firstTimetoken];
            if (result.isRecording) {
                NSTimeInterval firstTimeTokenAsUnix = [self _unixTimestampForPubNubTimetoken:firstTimetoken];
                NSTimeInterval currentUnixTimestamp = [[NSDate date] timeIntervalSince1970];
                XCTAssertEqualWithAccuracy(firstTimeTokenAsUnix, currentUnixTimestamp, 5);
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

- (NSTimeInterval)_unixTimestampForPubNubTimetoken:(NSNumber *)timetoken {
    NSTimeInterval rawTimetoken = [timetoken doubleValue];
    return rawTimetoken/pow(10, 7);
}

- (double)_timeIntervalForCurrentUnixTimestamp {
    NSTimeInterval currentUnixTimestamp = [[NSDate date] timeIntervalSince1970];
    return currentUnixTimestamp;
}

- (void)setRecorderToEnabledWithExpectation:(BOOL)enabled {
    __block XCTestExpectation *enableChangeExpectation = [self expectationWithDescription:@"enable expectation"];
    [[BKRRecorder sharedInstance] setEnabled:enabled withCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [enableChangeExpectation fulfill];
            enableChangeExpectation = nil;
        });
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)setPlayer:(BKRPlayer *)player withExpectationToEnabled:(BOOL)enabled {
    __block XCTestExpectation *enableChangeExpectation = [self expectationWithDescription:@"enable expectation"];
    [player setEnabled:enabled withCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [enableChangeExpectation fulfill];
            enableChangeExpectation = nil;
        });
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)setRecorderBeginAndEndRecordingBlocks {
    [BKRRecorder sharedInstance].beginRecordingBlock = ^void(NSURLSessionTask *task) {
        NSString *recordingExpectationString = [NSString stringWithFormat:@"Task: %@", task.BKR_globallyUniqueIdentifier];
        task.BKR_recordingExpectation = [self expectationWithDescription:recordingExpectationString];
    };
    
    [BKRRecorder sharedInstance].endRecordingBlock = ^void(NSURLSessionTask *task) {
        [task.BKR_recordingExpectation fulfill];
    };
}

- (BKRPlayer *)playerWithExpectedResults:(NSArray<BKRTestExpectedResult *> *)expectedResults {
    return [self playerWithMatcher:[BKRPlayheadMatcher class] withExpectedResults:expectedResults];
}

- (BKRPlayer *)playerWithMatcher:(Class<BKRRequestMatching>)matcherClass withExpectedResults:(NSArray<BKRTestExpectedResult *> *)expectedResults {
    BKRCassette *cassette = [self cassetteFromExpectedResults:expectedResults];
    NSArray<BKRScene *> *scenes = cassette.allScenes.copy;
    XCTAssertEqual(scenes.count, expectedResults.count, @"testCassette should have one valid scene right now");
    // assert on scene creation in cassette
    for (NSInteger i=0; i<expectedResults.count; i++) {
        BKRTestExpectedResult *result = [expectedResults objectAtIndex:i];
        BKRScene *scene = [scenes objectAtIndex:i];
        XCTAssertEqual(result.expectedNumberOfPlayingFrames, scene.allFrames.count);
        
    }
    BKRPlayer *player = [BKRPlayer playerWithMatcherClass:matcherClass];
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
            expectedErrorDict[@"uniqueIdentifier"] = result.taskUniqueIdentifier;
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
//    NSDate *lastDate = [NSDate dateWithTimeIntervalSince1970:0];
    NSNumber *lastDate = @(0);
    for (BKRFrame *frame in scene.allFrames) {
        // can't just assert that creation dates are in order, in case they have the same creation date for whatever reason (likely a result of mocking)
        // so just assert that they are in increasing order or equal (not in decreasing order)
        XCTAssertNotEqual([lastDate compare:frame.creationDate], NSOrderedDescending);
        lastDate = frame.creationDate;
    }
}

- (BKRCassette *)cassetteWithNumberOfScenes:(NSUInteger)numberOfScenes andCassetteCreationBlock:(BKRTestCassetteSceneCreationBlock)sceneCreationBlock {
    NSParameterAssert(numberOfScenes);
    NSParameterAssert(sceneCreationBlock);
    NSMutableArray<BKRTestExpectedResult *> *results = [NSMutableArray array];
    for (NSUInteger i=0; i < numberOfScenes; i++) {
        BKRTestExpectedResult *result = sceneCreationBlock(i);
        XCTAssertNotNil(result);
        [results addObject:result];
    }
    XCTAssertEqual(results.count, numberOfScenes);
    BKRCassette *cassette = [self cassetteFromExpectedResults:results.copy];
    XCTAssertNotNil(cassette);
    XCTAssertEqual(cassette.allScenes.count, numberOfScenes);
    return cassette;
}

- (void)assertCreationOfPlayableCassetteWithNumberOfScenes:(NSUInteger)numberOfScenes {
    [self cassetteWithNumberOfScenes:numberOfScenes andCassetteCreationBlock:^BKRTestExpectedResult *(NSUInteger iteration) {
        NSString *queryString = [NSString stringWithFormat:@"scene=%ld", (long)iteration];
        return [self HTTPBinGetRequestWithQueryString:queryString withRecording:NO];
    }];
}

- (NSMutableDictionary *)standardDataDictionary {
    return [@{
              @"class": @"BKRDataFrame",
              @"creationDate": @([[NSDate date] timeIntervalSince1970]),
              } mutableCopy];
}

- (NSMutableDictionary *)standardRequestDictionary {
    return [@{
              @"class": @"BKRRequestFrame",
              @"creationDate": @([[NSDate date] timeIntervalSince1970]),
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
              @"creationDate": @([[NSDate date] timeIntervalSince1970]),
              @"MIMEType": @"application/json",
              @"statusCode": @(200)
              } mutableCopy];
}

- (NSMutableDictionary *)standardErrorDictionary {
    return [@{
              @"class": @"BKRErrorFrame",
              @"creationDate": @([[NSDate date] timeIntervalSince1970]),
              } mutableCopy];
}

- (NSDictionary *)_expectedGETCurrentRequestAllHTTPHeaderFields {
    return @{
             @"Accept": @"*/*",
             @"Accept-Encoding": @"gzip, deflate",
             @"Accept-Language": @"en-us"
             };
}

- (NSDictionary *)_expectedPOSTCurrentRequestAllHTTPHeaderFieldsWithContentLength:(NSString *)contentLength {
    return @{
             @"Accept": @"*/*",
             @"Accept-Encoding": @"gzip, deflate",
             @"Accept-Language": @"en-us",
             @"Content-Length": contentLength,
             @"Content-Type": @"application/x-www-form-urlencoded"
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

- (NSDictionary *)_HTTPBinChunkedResponseAllHeaderFieldsWithContentLength:(NSString *)contentLengthString {
    NSMutableDictionary *mutableOriginalDictionary = [[self _HTTPBinResponseAllHeaderFieldsWithContentLength:contentLengthString] mutableCopy];
    mutableOriginalDictionary[@"Content-Type"] = @"application/octet-stream";
    return mutableOriginalDictionary.copy;
}

- (NSDictionary *)_PNResponseAllHeaderFieldsWithContentLength:(NSString *)contentLengthString {
    return @{
             @"Access-Control-Allow-Methods": @"GET",
             @"Access-Control-Allow-Origin": @"*",
             @"Cache-Control": @"no-cache",
             @"Connection": @"keep-alive",
             @"Content-Length": @"19",
             @"Content-Type": @"text/javascript; charset=\"UTF-8\"",
             @"Date": kBKRTestHTTPBinResponseDateStringValue
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
    expectedResult.expectedNumberOfPlayingFrames = 2;
    expectedResult.expectedNumberOfRecordingFrames = 5;
//    if (expectedResult.isRecording) {
//        expectedResult.expectedNumberOfFrames = 5;
//    } else {
//        expectedResult.expectedNumberOfFrames = 2;
//    }
//    expectedResult.expectedNumberOfFrames = 5;
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

- (BKRTestExpectedResult *)HTTPBinSimultaneousDelayedRequestWithDelay:(NSInteger)delay withRecording:(BOOL)isRecording {
    BKRTestExpectedResult *expectedResult = [BKRTestExpectedResult result];
    expectedResult.isRecording = isRecording;
    expectedResult.isSimultaneous = YES;
    expectedResult.URLString = @"https://httpbin.org/delay/3";
    expectedResult.URLString = [NSString stringWithFormat:@"https://httpbin.org/delay/%ld", (long)delay];
    expectedResult.hasCurrentRequest = YES;
    expectedResult.expectedNumberOfRecordingFrames = 6;
    expectedResult.expectedNumberOfPlayingFrames = 4;
//    if (expectedResult.isRecording) {
//        expectedResult.expectedNumberOfFrames = 6;
//    } else {
//        expectedResult.expectedNumberOfFrames = 4;
//    }
    //    expectedResult.expectedNumberOfFrames = 6;
    //    expectedResult.currentRequestAllHTTPHeaderFields = [self _HTTPBinCurrentRequestAllHTTPHeaderFields];
    expectedResult.expectedSceneNumber = 0;
    expectedResult.responseCode = 200;
    expectedResult.currentRequestAllHTTPHeaderFields = [self _expectedGETCurrentRequestAllHTTPHeaderFields];
    expectedResult.responseAllHeaderFields = [self _HTTPBinResponseAllHeaderFieldsWithContentLength:@"356"];
    expectedResult.receivedJSON = @{
                                    @"args": @{},
                                    @"data": @"",
                                    @"files": @{},
                                    @"form": @{},
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
    expectedResult.currentRequestAllHTTPHeaderFields = [self _expectedGETCurrentRequestAllHTTPHeaderFields];
    expectedResult.responseCode = 200;
    expectedResult.responseAllHeaderFields = [self _HTTPBinResponseAllHeaderFieldsWithContentLength:@"338"];
//    if (expectedResult.isRecording) {
//        expectedResult.expectedNumberOfFrames = 6;
//    } else {
//        expectedResult.expectedNumberOfFrames = 4;
//    }
    //    expectedResult.expectedNumberOfFrames = 6;
    expectedResult.expectedNumberOfPlayingFrames = 4;
    expectedResult.expectedNumberOfRecordingFrames = 6;
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

- (BKRTestExpectedResult *)HTTPBinDripDataWithRecording:(BOOL)isRecording {
    BKRTestExpectedResult *expectedResult = [BKRTestExpectedResult result];
    expectedResult.isRecording = isRecording;
    expectedResult.hasCurrentRequest = YES;
    expectedResult.URLString = @"https://httpbin.org/drip?numbytes=30000&duration=0&code=200";
    expectedResult.currentRequestAllHTTPHeaderFields = [self _expectedGETCurrentRequestAllHTTPHeaderFields];
    expectedResult.responseCode = 200;
    expectedResult.responseAllHeaderFields = [self _HTTPBinChunkedResponseAllHeaderFieldsWithContentLength:@"30000"];
    expectedResult.expectedNumberOfPlayingFrames = 4;
    expectedResult.expectedNumberOfRecordingFrames = 6;
    
    return expectedResult;
}

- (BKRTestExpectedResult *)HTTPBinRedirectWithRecording:(BOOL)isRecording {
    BKRTestExpectedResult *expectedResult = [BKRTestExpectedResult result];
    expectedResult.isRecording = isRecording;
    expectedResult.URLString = @"http://httpbin.org/redirect/6";
    
    return expectedResult;
}

- (BKRTestExpectedResult *)HTTPBinPostRequestWithRecording:(BOOL)isRecording {
    BKRTestExpectedResult *result = [BKRTestExpectedResult result];
    result.isRecording = isRecording;
    result.hasCurrentRequest = YES;
    result.currentRequestAllHTTPHeaderFields = [self _expectedPOSTCurrentRequestAllHTTPHeaderFieldsWithContentLength:@"20"];
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
    result.expectedNumberOfPlayingFrames = 4;
    result.expectedNumberOfRecordingFrames = 6;
//    if (result.isRecording) {
//        result.expectedNumberOfFrames = 6;
//    } else {
//        result.expectedNumberOfFrames = 4;
//    }
    //    result.expectedNumberOfFrames = 6;
    return result;
}

#pragma mark - PNHelpers

- (BKRTestExpectedResult *)PNGetTimeTokenWithRecording:(BOOL)isRecording {
    BKRTestExpectedResult *expectedResult = [BKRTestExpectedResult result];
    expectedResult.isRecording = isRecording;
    expectedResult.hasCurrentRequest = YES;
    expectedResult.URLString = @"https://pubsub.pubnub.com/time/0";
    expectedResult.currentRequestAllHTTPHeaderFields = [self _expectedGETCurrentRequestAllHTTPHeaderFields];
    expectedResult.responseCode = 200;
    expectedResult.responseAllHeaderFields = [self _PNResponseAllHeaderFieldsWithContentLength:@"19"];
//    if (expectedResult.isRecording) {
//        expectedResult.expectedNumberOfFrames = 6;
//    } else {
//        expectedResult.expectedNumberOfFrames = 4;
//    }
    expectedResult.expectedNumberOfRecordingFrames = 6;
    expectedResult.expectedNumberOfPlayingFrames = 4;
    //    expectedResult.expectedNumberOfFrames = 6;
    expectedResult.receivedJSON = @[
                                    @([[NSDate date] timeIntervalSince1970])
                                    ];
    return expectedResult;
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

- (void)assertNoFileAtRecordingCassetteFilePath:(NSString *)cassetteFilePath {
    // now remove anything at that path if there is something
    NSError *testResultRemovalError = nil;
    BOOL fileExists = [BKRFilePathHelper filePathExists:cassetteFilePath];
    if (fileExists) {
        BOOL removeTestResults = [[NSFileManager defaultManager] removeItemAtPath:cassetteFilePath error:&testResultRemovalError];
        XCTAssertTrue(removeTestResults);
        XCTAssertNil(testResultRemovalError, @"Couldn't remove test results: %@", testResultRemovalError.localizedDescription);
    }
    
    XCTAssertFalse([BKRFilePathHelper filePathExists:cassetteFilePath]);
}

- (void)assertCassettePath:(NSString *)cassetteFilePath matchesExpectedResults:(NSArray<BKRTestExpectedResult *> *)expectedResults {
    XCTAssertTrue([BKRFilePathHelper filePathExists:cassetteFilePath]);
    NSDictionary *cassetteDictionary = [BKRFilePathHelper dictionaryForPlistFilePath:cassetteFilePath];
    XCTAssertTrue([cassetteDictionary isKindOfClass:[NSDictionary class]]);
    XCTAssertNotNil(cassetteDictionary[@"version"]);
    XCTAssertTrue([cassetteDictionary[@"version"] isKindOfClass:[NSString class]]);
    XCTAssertTrue([cassetteDictionary[@"creationDate"] isKindOfClass:[NSDate class]]);
    NSArray *scenes = cassetteDictionary[@"scenes"];
    XCTAssertEqual(expectedResults.count, scenes.count);
    // if there are no expected recordings, then there are no more comparisons left
    if (!expectedResults.count) {
        return;
    }
    NSMutableArray<BKRTestExpectedResult *> *assertingExpectedResults = expectedResults.mutableCopy;
    BOOL shouldCheckAssertingExpectedResultsArray = NO;
    XCTAssertNotEqual(assertingExpectedResults.count, 0);
    for (NSInteger i=0; i < expectedResults.count; i++) {
        NSDictionary *scene = [scenes objectAtIndex:i];
        XCTAssertTrue([scene isKindOfClass:[NSDictionary class]]);
        NSString *uniqueIdentifier = scene[@"uniqueIdentifier"];
        XCTAssertNotNil(uniqueIdentifier);
        BKRTestExpectedResult *recording = [expectedResults objectAtIndex:i];
        // if it's simultaneous, shuffle the expected results because order of scenes may be off in the recording
        if (recording.isSimultaneous) {
            // check the asserting array at the end of the test
            shouldCheckAssertingExpectedResultsArray = YES;
            for (BKRTestExpectedResult *assertingResult in assertingExpectedResults) {
                // hardcoded getting the originalRequestURLString, this is brittle, may break, ok test shortcut
                NSString *originalRequestURLString = scene[@"frames"][0][@"URL"];
                // if the URLs match, then reassign
                if ([assertingResult.URLString isEqualToString:originalRequestURLString]) {
                    // reassign recording to check that is pull from the mutable asserting expected results array
                    recording = assertingResult;
                    // remove the expected result from the pool of checks
                    [assertingExpectedResults removeObject:assertingResult];
                    // break out of the for loop so we can test things
                    break;
                }
            }
        }
        // don't assert order for simultaneous requests!
        if (!recording.isSimultaneous) {
            XCTAssertEqual(recording.expectedSceneNumber, i);
        }
        XCTAssertNotNil(recording);
        NSArray *frames = scene[@"frames"];
        XCTAssertNotNil(frames);
        NSInteger numberOfRequestChecks = 0;
        XCTAssertEqual(recording.expectedNumberOfRecordingFrames, frames.count, @"frames: %@", frames);
        for (NSDictionary *frame in frames) {
            XCTAssertEqualObjects(frame[@"uniqueIdentifier"], uniqueIdentifier);
            XCTAssertTrue([frame[@"creationDate"] isKindOfClass:[NSNumber class]]);
            NSString *frameClass = frame[@"class"];
            XCTAssertNotNil(frameClass);
            if ([frameClass isEqualToString:@"BKRErrorFrame"]) {
                XCTAssertEqual([frame[@"code"] integerValue], recording.errorCode);
                XCTAssertEqualObjects(frame[@"domain"], recording.errorDomain);
                NSDictionary *finalUserInfo;
                if (recording.errorUserInfo) {
                    NSMutableDictionary *comparingDictionary = recording.errorUserInfo.mutableCopy;
                    if (comparingDictionary[NSURLErrorFailingURLErrorKey]) {
                        comparingDictionary[NSURLErrorFailingURLErrorKey] = [recording.errorUserInfo[NSURLErrorFailingURLErrorKey] absoluteString];
                    }
                    finalUserInfo = comparingDictionary.copy;
                }
                XCTAssertEqualObjects(frame[@"userInfo"], finalUserInfo);
            } else if ([frameClass isEqualToString:@"BKRDataFrame"]) {
                XCTAssertNotNil(recording.receivedData, @"How can we have a data frame but not expect data?");
                [self _assertExpectedResult:recording withData:frame[@"data"]];
            } else if ([frameClass isEqualToString:@"BKRResponseFrame"]) {
                XCTAssertEqualObjects(frame[@"URL"], recording.URLString);
                XCTAssertNotNil(frame[@"MIMEType"]);
                XCTAssertEqual([frame[@"statusCode"] integerValue], recording.responseCode);
                // check response header fields
                [self _assertExpectedResult:recording withActualResponseHeaderFields:frame[@"allHeaderFields"]];
            } else if ([frameClass isEqualToString:@"BKRRequestFrame"]) {
                XCTAssertTrue(numberOfRequestChecks < 4, @"only expecting an original request and a current request");
                XCTAssertEqualObjects(frame[@"URL"], recording.URLString);
                XCTAssertNotNil(frame[@"timeoutInterval"]);
                XCTAssertNotNil(frame[@"allowsCellularAccess"]);
                XCTAssertNotNil(frame[@"HTTPShouldHandleCookies"]);
                XCTAssertNotNil(frame[@"HTTPShouldUsePipelining"]);
                if (recording.HTTPMethod) {
                    XCTAssertEqualObjects(recording.HTTPMethod, frame[@"HTTPMethod"]);
                }
                if (numberOfRequestChecks == 0) {
                    // original request has the upload data, the current request does not
                    if (recording.HTTPBody) {
                        XCTAssertEqualObjects(recording.HTTPBody, frame[@"HTTPBody"]);
                    }
                    // should assert on headers too
                    if (recording.originalRequestAllHTTPHeaderFields) {
                        XCTAssertEqualObjects(recording.originalRequestAllHTTPHeaderFields, frame[@"allHTTPHeaderFields"]);
                    }
                } else if (
                           (numberOfRequestChecks > 0) &&
                           (numberOfRequestChecks < 4)
                           ) {
                    // expected to have updated current requests
                } else if (numberOfRequestChecks == 4) {
                    if (recording.currentRequestAllHTTPHeaderFields) {
                        [self _assertExpectedResult:recording withActualCurrentRequestHeaderFields:frame[@"allHTTPHeaderFields"]];
//                        [self _assertExpectedResult:recording withActualResponseHeaderFields:frame[@"allHTTPHeaderFields"]];
//                        XCTAssertEqualObjects(recording.currentRequestAllHTTPHeaderFields, frame[@"allHTTPHeaderFields"]);
                    }
                } else {
                    XCTFail(@"not expecting to have more than 2 requests: %@", frame);
                }
                numberOfRequestChecks++;
                
            } else {
                XCTFail(@"frameClass is unknown type: %@", frameClass);
            }
        }
        // assert order of frames and scenes
    }
    if (shouldCheckAssertingExpectedResultsArray) {
        XCTAssertEqual(assertingExpectedResults.count, 0, @"Should have tested all expected results by end of test");
    }
}

#pragma mark - VCR helpers

- (void)_setBeginAndEndRecordingBlocksForConfiguration:(BKRConfiguration *)configuration {
    configuration.beginRecordingBlock = ^void(NSURLSessionTask *task) {
        NSString *recordingExpectationString = [NSString stringWithFormat:@"Task: %@", task.BKR_globallyUniqueIdentifier];
        task.BKR_recordingExpectation = [self expectationWithDescription:recordingExpectationString];
    };
    
    configuration.endRecordingBlock = ^void(NSURLSessionTask *task) {
        [task.BKR_recordingExpectation fulfill];
    };
}

- (void)insertBlankCassetteIntoVCR:(id<BKRVCRActions>)vcr {
    __block XCTestExpectation *insertExpectation = [self expectationWithDescription:@"insert expectation"];
    XCTAssertTrue([vcr insert:^BKRCassette *{
        return [BKRCassette cassette];
    } completionHandler:^(BOOL result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [insertExpectation fulfill];
            insertExpectation = nil;
        });
    }]);
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    XCTAssertEqual(vcr.state, BKRVCRStateStopped);
}

- (void)insertBlankCassetteIntoTestVCR:(id<BKRTestVCRActions>)vcr {
    XCTAssertTrue([vcr insert:^BKRCassette *{
        return [BKRCassette cassette];
    }]);
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    XCTAssertEqual(vcr.state, BKRVCRStateStopped);
}

- (void)insertCassetteFilePath:(NSString *)cassetteFilePath intoVCR:(id<BKRVCRActions>)vcr {
    XCTAssertNotNil(cassetteFilePath);
    XCTAssertNotNil(vcr);
    __block XCTestExpectation *insertExpectation = [self expectationWithDescription:@"insert expectation"];
    XCTAssertTrue([vcr insert:^BKRCassette *{
        NSDictionary *cassetteDictionary = [BKRFilePathHelper dictionaryForPlistFilePath:cassetteFilePath];
        BKRCassette *cassette = nil;
        cassette = [BKRCassette cassetteFromDictionary:cassetteDictionary];
        XCTAssertNotNil(cassette, @"not trying to insert a nil cassette");
        return cassette;
    } completionHandler:^(BOOL result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [insertExpectation fulfill];
            insertExpectation = nil;
        });
    }]);
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    XCTAssertEqual(vcr.state, BKRVCRStateStopped);
}

- (void)insertCassetteFilePath:(NSString *)cassetteFilePath intoTestVCR:(id<BKRTestVCRActions>)vcr {
    XCTAssertNotNil(cassetteFilePath);
    XCTAssertNotNil(vcr);
    XCTAssertTrue([vcr insert:^BKRCassette *{
        NSDictionary *cassetteDictionary = [BKRFilePathHelper dictionaryForPlistFilePath:cassetteFilePath];
        BKRCassette *cassette = nil;
        cassette = [BKRCassette cassetteFromDictionary:cassetteDictionary];
        XCTAssertNotNil(cassette, @"not trying to insert a nil cassette");
        return cassette;
    }]);
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    XCTAssertEqual(vcr.state, BKRVCRStateStopped);
}

- (void)resetVCR:(id<BKRVCRActions>)vcr {
    __block XCTestExpectation *resetExpectation = [self expectationWithDescription:@"reset expectation"];
    [vcr resetWithCompletionBlock:^(BOOL result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            XCTAssertTrue(result);
            [resetExpectation fulfill];
            resetExpectation = nil;
        });
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    XCTAssertEqual(vcr.state, BKRVCRStateStopped);
}

- (void)resetTestVCR:(id<BKRTestVCRActions>)vcr {
    [vcr reset];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    XCTAssertEqual(vcr.state, BKRVCRStateStopped);
}

- (BOOL)ejectCassetteWithFilePath:(NSString *)cassetteFilePath fromVCR:(id<BKRVCRActions>)vcr {
    __block XCTestExpectation *ejectExpectation = [self expectationWithDescription:@"eject"];
    BOOL result = [vcr eject:^NSString *(BKRCassette *cassette) {
        return cassetteFilePath;
    } completionHandler:^(BOOL result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ejectExpectation fulfill];
            ejectExpectation = nil;
        });
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    XCTAssertEqual(vcr.state, BKRVCRStateStopped);
    return result;
}

- (BOOL)ejectCassetteWithFilePath:(NSString *)cassetteFilePath fromTestVCR:(id<BKRTestVCRActions>)vcr {
    BOOL result = [vcr eject:^NSString *(BKRCassette *cassette) {
        return cassetteFilePath;
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    XCTAssertEqual(vcr.state, BKRVCRStateStopped);
    return result;
}

- (void)playVCR:(id<BKRVCRActions>)vcr {
    __block XCTestExpectation *playExpectation = [self expectationWithDescription:@"start playing expectation"];
    [vcr playWithCompletionBlock:^(BOOL result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            XCTAssertTrue(result);
            [playExpectation fulfill];
            playExpectation = nil;
        });
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    XCTAssertEqual(vcr.state, BKRVCRStatePlaying);
}

- (void)playTestVCR:(id<BKRTestVCRActions>)vcr {
    [vcr play];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    XCTAssertEqual(vcr.state, BKRVCRStatePlaying);
}

- (void)recordVCR:(id<BKRVCRActions>)vcr {
    __block XCTestExpectation *recordExpectation = [self expectationWithDescription:@"start recording expectation"];
    [vcr recordWithCompletionBlock:^(BOOL result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            XCTAssertTrue(result);
            [recordExpectation fulfill];
            recordExpectation = nil;
        });
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    XCTAssertEqual(vcr.state, BKRVCRStateRecording);
}

- (void)recordTestVCR:(id<BKRTestVCRActions>)vcr {
    [vcr record];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    XCTAssertEqual(vcr.state, BKRVCRStateRecording);
}

- (void)stopVCR:(id<BKRVCRActions>)vcr {
    __block XCTestExpectation *stopExpectation = [self expectationWithDescription:@"stop vcr expectation"];
    [vcr stopWithCompletionBlock:^(BOOL result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            XCTAssertTrue(result);
            [stopExpectation fulfill];
            stopExpectation = nil;
        });
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    XCTAssertEqual(vcr.state, BKRVCRStateStopped);
}

- (void)stopTestVCR:(id<BKRTestVCRActions>)vcr {
    [vcr stop];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    XCTAssertEqual(vcr.state, BKRVCRStateStopped);
}

@end
