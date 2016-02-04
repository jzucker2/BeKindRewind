//
//  XCTestCase+BKRAdditions.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/19/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import "XCTestCase+BKRAdditions.h"
#import <BeKindRewind/BKRDataFrame.h>
#import <BeKindRewind/BKRScene.h>
#import <BeKindRewind/BKRRequestFrame.h>
#import <BeKindRewind/BKRResponseFrame.h>
#import <BeKindRewind/BKRErrorFrame.h>
#import <BeKindRewind/BKRRecordableRawFrame.h>
#import <BeKindRewind/BKRPlayableRawFrame.h>
#import <BeKindRewind/BKRPlayableCassette.h>
#import <BeKindRewind/BKRRecordableCassette.h>
#import <BeKindRewind/NSURLSessionTask+BKRAdditions.h>
#import <BeKindRewind/BKRRecordingEditor.h>
#import <BeKindRewind/BKRRecorder.h>
#import <BeKindRewind/BKRRecordableScene.h>
#import <BeKindRewind/BKRPlayer.h>

@implementation BKRExpectedScenePlistDictionaryBuilder

+ (instancetype)builder {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _hasCurrentRequest = YES;
        _hasResponse = YES;
    }
    return self;
}

@end

@implementation BKRExpectedRecording

+ (instancetype)recording {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
//        _HTTPMethod = @"GET";
        _cancelling = NO;
    }
    return self;
}

@end

@implementation XCTestCase (BKRAdditions)

- (void)recordingTaskForHTTPBinWithExpectedRecording:(BKRExpectedRecording *)expectedRecording taskCompletionAssertions:(taskCompletionHandler)taskCompletion taskTimeoutAssertions:(taskTimeoutCompletionHandler)taskTimeout {
//    __block NSData *receivedData;
//    __block NSURLResponse *receivedResponse;
    
    [self recordingTaskWithExpectedRecording:expectedRecording taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        if (expectedRecording.isCancelling) {
            
        } else {
            NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if ([expectedRecording.HTTPMethod isEqualToString:@"POST"]) {
                NSDictionary *formDict = dataDict[@"form"];
                // for this service, need to fish out the data sent
                NSArray *formKeys = formDict.allKeys;
                NSString *rawReceivedDataString = formKeys.firstObject;
                NSDictionary *receivedDataDictionary = [NSJSONSerialization JSONObjectWithData:[rawReceivedDataString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                // ensure that result from network is as expected
                XCTAssertEqualObjects(expectedRecording.sentJSON, receivedDataDictionary);
            } else {
                XCTAssertEqualObjects(dataDict[@"args"], expectedRecording.receivedJSON);
            }
        }
        
        if (taskCompletion) {
            taskCompletion(task, data, response, error);
        }
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        
        if (taskTimeout) {
            taskTimeout(task, error);
        }
    }];
}

- (void)recordingTaskWithExpectedRecording:(BKRExpectedRecording *)expectedRecording taskCompletionAssertions:(taskCompletionHandler)taskCompletion taskTimeoutAssertions:(taskTimeoutCompletionHandler)taskTimeout {
    NSURL *expectedURL = [NSURL URLWithString:expectedRecording.URLString];
    NSMutableURLRequest *basicAssertRequest = [NSMutableURLRequest requestWithURL:expectedURL];
    if (expectedRecording.HTTPMethod) {
        basicAssertRequest.HTTPMethod = expectedRecording.HTTPMethod;
    }
    
    // include one or the other but not both
    if (expectedRecording.sentJSON) {
        basicAssertRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:expectedRecording.sentJSON options:NSJSONWritingPrettyPrinted error:nil];
    } else if (expectedRecording.HTTPBody) {
        basicAssertRequest.HTTPBody = expectedRecording.HTTPBody;
    }
    __block NSData *receivedData;
    __block NSURLResponse *receivedResponse;
    __block NSError *receivedError;
    
    taskCompletionHandler localCompletionHandler = ^void(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertNotNil([BKRRecorder sharedInstance].currentCassette);
        XCTAssertNotNil(data);
        if (expectedRecording.isCancelling) {
            XCTAssertNotNil(error);
            XCTAssertEqual(expectedRecording.expectedErrorCode, error.code);
            XCTAssertEqualObjects(expectedRecording.expectedErrorDomain, error.domain);
            XCTAssertEqualObjects(expectedRecording.expectedErrorUserInfo, error.userInfo);
            receivedError = error;
        } else {
            XCTAssertNil(error);
            XCTAssertNotNil(response);
            XCTAssertEqual([(NSHTTPURLResponse *)response statusCode], expectedRecording.responseStatusCode);
            receivedData = data;
            receivedResponse = response;
        }
        if (taskCompletion) {
            taskCompletion(task, data, response, error);
        }
    };
    
    taskTimeoutCompletionHandler localTimeoutHandler = ^void(NSURLSessionTask *task, NSError *error) {
        BKRRecordableScene *expectedScene = [BKRRecorder sharedInstance].allScenes[expectedRecording.expectedSceneNumber];
        XCTAssertNotNil(expectedScene);
        XCTAssertEqual(expectedScene.allFrames.count, expectedRecording.expectedNumberOfFrames);
        NSURLRequest *originalRequest = task.originalRequest;
        BKRRequestFrame *originalRequestFrame = expectedScene.originalRequest;
        XCTAssertNotNil(originalRequestFrame);
        [self assertRequest:originalRequestFrame withRequest:originalRequest extraAssertions:nil];
        if (expectedRecording.isCancelling) {
            XCTAssertEqual(expectedScene.allRequestFrames.count, 1);
            XCTAssertEqual(expectedScene.allErrorFrames.count, 1);
        } else {
            XCTAssertEqual(expectedScene.allRequestFrames.count, 2);
            XCTAssertEqual(expectedScene.allDataFrames.count, 1);
            XCTAssertEqual(expectedScene.allResponseFrames.count, 1);
            BKRDataFrame *dataFrame = expectedScene.allDataFrames.firstObject;
            [self assertData:dataFrame withData:receivedData extraAssertions:nil];
            BKRResponseFrame *responseFrame = expectedScene.allResponseFrames.firstObject;
            [self assertResponse:responseFrame withResponse:receivedResponse extraAssertions:nil];
            NSURLRequest *currentRequest = task.currentRequest;
            BKRRequestFrame *currentRequestFrame = expectedScene.currentRequest;
            XCTAssertNotNil(currentRequestFrame);
            [self assertRequest:currentRequestFrame withRequest:currentRequest extraAssertions:nil];
        }
        [self assertFramesOrder:expectedScene extraAssertions:nil];
        if (taskTimeout) {
            taskTimeout(task, error);
        }
    };
    
    if (expectedRecording.isCancelling) {
        [self _executeCancellingRequest:basicAssertRequest withExpectationString:@"cancelling assert" taskCompletionAssertions:localCompletionHandler taskTimeoutAssertions:localTimeoutHandler];
    } else {
        [self _executeRequest:basicAssertRequest withExpectationString:@"simple assert task" taskCompletionAssertions:localCompletionHandler tastTimeoutAssertions:localTimeoutHandler];
    }
}

- (void)getTaskWithURLString:(NSString *)URLString taskCompletionAssertions:(taskCompletionHandler)taskCompletionHandler taskTimeoutAssertions:(taskTimeoutCompletionHandler)taskTimeoutHandler {
    NSURL *basicGetURL = [NSURL URLWithString:URLString];
    NSURLRequest *basicGetRequest = [NSURLRequest requestWithURL:basicGetURL];
    [self _executeRequest:basicGetRequest withExpectationString:@"basicGetExpectation" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertNil(error);
        if (taskCompletionHandler) {
            taskCompletionHandler(task, data, response, error);
        }
    } tastTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        if (taskTimeoutHandler) {
            taskTimeoutHandler(task, error);
        }
    }];
}

- (void)cancellingGetTaskWithURLString:(NSString *)URLString taskCompletionAssertions:(taskCompletionHandler)taskCompletionHandler taskTimeoutAssertions:(taskTimeoutCompletionHandler)taskTimeoutHandler {
    NSURL *basicCancellingURL = [NSURL URLWithString:URLString];
    NSURLRequest *basicCancellingRequest = [NSURLRequest requestWithURL:basicCancellingURL];
    [self _executeCancellingRequest:basicCancellingRequest withExpectationString:@"cancelTask" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        if (taskCompletionHandler) {
            taskCompletionHandler(task, data, response, error);
        }
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        if (taskTimeoutHandler) {
            taskTimeoutHandler(task, error);
        }
    }];
}

- (void)post:(NSData *)postData withURLString:(NSString *)URLString taskCompletionAssertions:(taskCompletionHandler)taskCompletionHandler taskTimeoutAssertions:(taskTimeoutCompletionHandler)taskTimeoutHandler {
    NSURL *basicPostURL = [NSURL URLWithString:URLString];
    NSMutableURLRequest *basicPostRequest = [NSMutableURLRequest requestWithURL:basicPostURL];
    basicPostRequest.HTTPMethod = @"POST";
    basicPostRequest.HTTPBody = postData;
    [self _executeRequest:basicPostRequest withExpectationString:@"basicPostExpectation" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertNil(error);
        if (taskCompletionHandler) {
            taskCompletionHandler(task, data, response, error);
        }
    } tastTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        if (taskTimeoutHandler) {
            taskTimeoutHandler(task, error);
        }
    }];
}

- (void)postJSON:(id)JSON withURLString:(NSString *)URLString taskCompletionAssertions:(taskCompletionHandler)taskCompletionHandler taskTimeoutAssertions:(taskTimeoutCompletionHandler)taskTimeoutHandler {
    NSData *postData = [NSJSONSerialization dataWithJSONObject:JSON options:NSJSONWritingPrettyPrinted error:nil];
    [self post:postData withURLString:URLString taskCompletionAssertions:taskCompletionHandler taskTimeoutAssertions:taskTimeoutHandler];
}

- (void)_executeRequest:(NSURLRequest *)request withExpectationString:(NSString *)expectationString taskCompletionAssertions:(taskCompletionHandler)taskCompletionHandler tastTimeoutAssertions:(taskTimeoutCompletionHandler)taskTimeoutHandler {
    __block XCTestExpectation *expectation = [self expectationWithDescription:expectationString];
    __block NSURLSessionDataTask *task = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (taskCompletionHandler) {
            taskCompletionHandler(task, data, response, error);
        }
        [expectation fulfill];
        expectation = nil;
    }];
    XCTAssertEqual(task.state, NSURLSessionTaskStateSuspended);
    [task resume];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertEqual(task.state, NSURLSessionTaskStateCompleted);
        XCTAssertNotNil(task.originalRequest);
        XCTAssertNotNil(task.currentRequest);
        if (taskTimeoutHandler) {
            taskTimeoutHandler(task, error);
        }
    }];
}

- (void)_executeCancellingRequest:(NSURLRequest *)request withExpectationString:(NSString *)expectationString taskCompletionAssertions:(taskCompletionHandler)taskCompletionHandler taskTimeoutAssertions:(taskTimeoutCompletionHandler)taskTimeoutHandler {
    __block XCTestExpectation *expectation = [self expectationWithDescription:expectationString];
    __block NSURLSessionDataTask *task = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        if (taskCompletionHandler) {
            taskCompletionHandler(task, data, response, error);
        }
        [expectation fulfill];
        expectation = nil;
    }];
    XCTAssertEqual(task.state, NSURLSessionTaskStateSuspended);
    [task resume];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [task cancel];
        XCTAssertNotEqual(task.state, NSURLSessionTaskStateRunning);
        XCTAssertNotEqual(task.state, NSURLSessionTaskStateSuspended);
    });
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotEqual(task.state, NSURLSessionTaskStateRunning);
        XCTAssertNotEqual(task.state, NSURLSessionTaskStateSuspended);
        XCTAssertNotNil(task.originalRequest);
        XCTAssertNotNil(task.currentRequest);
        if (taskTimeoutHandler) {
            taskTimeoutHandler(task, error);
        }
    }];
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

- (NSDictionary *)expectedCassetteDictionaryWithSceneBuilders:(NSArray<BKRExpectedScenePlistDictionaryBuilder *> *)expectedPlistBuilders {
    NSDate *expectedCassetteDictCreationDate = [NSDate date];
    NSMutableArray *expectedPlistSceneDicts = [NSMutableArray array];
    for (BKRExpectedScenePlistDictionaryBuilder *expectedPlistBuilder in expectedPlistBuilders) {
        NSMutableArray *framesArray = [NSMutableArray array];
        NSMutableDictionary *expectedOriginalRequestDict = [self standardRequestDictionary];
        expectedOriginalRequestDict[@"URL"] = expectedPlistBuilder.URLString;
        expectedOriginalRequestDict[@"uniqueIdentifier"] = expectedPlistBuilder.taskUniqueIdentifier;
        if (expectedPlistBuilder.originalRequestAllHTTPHeaderFields) {
            expectedOriginalRequestDict[@"allHTTPHeaderFields"] = expectedPlistBuilder.originalRequestAllHTTPHeaderFields;
        }
        if (expectedPlistBuilder.HTTPMethod) {
            expectedOriginalRequestDict[@"HTTPMethod"] = expectedPlistBuilder.HTTPMethod;
        }
        [framesArray addObject:expectedOriginalRequestDict];
        
        if (expectedPlistBuilder.hasCurrentRequest) {
            NSMutableDictionary *expectedCurrentRequestDict = [self standardRequestDictionary];
            expectedCurrentRequestDict[@"URL"] = expectedPlistBuilder.URLString;
            expectedCurrentRequestDict[@"uniqueIdentifier"] = expectedPlistBuilder.taskUniqueIdentifier;
            if (expectedPlistBuilder.currentRequestAllHTTPHeaderFields) {
                expectedCurrentRequestDict[@"allHTTPHeaderFields"] = expectedPlistBuilder.currentRequestAllHTTPHeaderFields;
            }
            if (expectedPlistBuilder.HTTPMethod) {
                expectedCurrentRequestDict[@"HTTPMethod"] = expectedPlistBuilder.HTTPMethod;
            }
            [framesArray addObject:expectedCurrentRequestDict];
        }
        
        if (expectedPlistBuilder.hasResponse) {
            NSMutableDictionary *expectedResponseDict = [self standardResponseDictionary];
            expectedResponseDict[@"URL"] = expectedPlistBuilder.URLString;
            expectedResponseDict[@"uniqueIdentifier"] = expectedPlistBuilder.taskUniqueIdentifier;
            expectedResponseDict[@"allHeaderFields"] = expectedPlistBuilder.responseAllHeaderFields;
            [framesArray addObject:expectedResponseDict];
        }
        
        if (
            expectedPlistBuilder.receivedJSON ||
            expectedPlistBuilder.receivedData
            ) {
            NSMutableDictionary *expectedDataDict = [self standardDataDictionary];
            expectedDataDict[@"uniqueIdentifier"] = expectedPlistBuilder.taskUniqueIdentifier;
            if (expectedPlistBuilder.receivedJSON) {
                expectedDataDict[@"data"] = [NSJSONSerialization dataWithJSONObject:expectedPlistBuilder.receivedJSON options:kNilOptions error:nil];
            } else {
                expectedDataDict[@"data"] = expectedPlistBuilder.receivedData;
            }
            [framesArray addObject:expectedDataDict];
        }
        
        if (expectedPlistBuilder.errorCode && expectedPlistBuilder.errorDomain) {
            NSMutableDictionary *expectedErrorDict = [self standardErrorDictionary];
            expectedErrorDict[@"code"] = @(expectedPlistBuilder.errorCode);
            expectedErrorDict[@"domain"] = expectedPlistBuilder.errorDomain;
            if (expectedPlistBuilder.errorUserInfo) {
                expectedErrorDict[@"userInfo"] = expectedPlistBuilder.errorUserInfo;
            }
            [framesArray addObject:expectedErrorDict];
        }
        
        NSDictionary *sceneDict = @{
                                    @"uniqueIdentifier": expectedPlistBuilder.taskUniqueIdentifier,
                                    @"frames": framesArray.copy
                                    };
        [expectedPlistSceneDicts addObject:sceneDict];
    }
    
    return [self expectedCassetteDictionaryWithCreationDate:expectedCassetteDictCreationDate sceneDictionaries:expectedPlistSceneDicts];
}

- (NSDictionary *)expectedCassetteDictionaryWithCreationDate:(NSDate *)creationDate sceneDictionaries:(NSArray<NSDictionary *> *)sceneDictionaries {
    return @{
             @"creationDate": creationDate,
             @"scenes": sceneDictionaries
             };
}

- (NSDictionary *)dictionaryWithRequest:(NSURLRequest *)request forTask:(NSURLSessionTask *)task {
    NSMutableDictionary *requestFrameDict = [self standardRequestDictionary];
    requestFrameDict[@"URL"] = request.URL.absoluteString;
    requestFrameDict[@"uniqueIdentifier"] = task.globallyUniqueIdentifier;
    requestFrameDict[@"timeoutInterval"] = @(request.timeoutInterval);
    requestFrameDict[@"allowsCellularAccess"] = @(request.allowsCellularAccess);
    requestFrameDict[@"HTTPShouldHandleCookies"] = @(request.HTTPShouldHandleCookies);
    requestFrameDict[@"HTTPShouldUsePipelining"] = @(request.HTTPShouldUsePipelining);
    if (request.HTTPBody) {
        requestFrameDict[@"HTTPBody"] = request.HTTPBody;
    }
    if (request.HTTPMethod) {
        requestFrameDict[@"HTTPMethod"] = request.HTTPMethod;
    }
    if (request.allHTTPHeaderFields) {
        requestFrameDict[@"allHTTPHeaderFields"] = request.allHTTPHeaderFields.copy;
    }
    return requestFrameDict.copy;
}

- (NSDictionary *)dictionaryWithResponse:(NSURLResponse *)response forTask:(NSURLSessionTask *)task {
    NSMutableDictionary *responseFrameDict = [self standardResponseDictionary];
    NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse *)response;
    responseFrameDict[@"uniqueIdentifier"] = task.globallyUniqueIdentifier;
    responseFrameDict[@"URL"] = castedResponse.URL.absoluteString;
    responseFrameDict[@"MIMEType"] = castedResponse.MIMEType;
    responseFrameDict[@"statusCode"] = @(castedResponse.statusCode);
    if (castedResponse.allHeaderFields) {
        responseFrameDict[@"allHeaderFields"] = castedResponse.allHeaderFields.copy;
    }
    return responseFrameDict.copy;
}

- (NSDictionary *)dictionaryWithData:(NSData *)data forTask:(NSURLSessionTask *)task {
    NSMutableDictionary *dataFrameDict = [self standardDataDictionary];
    dataFrameDict[@"uniqueIdentifier"] = task.globallyUniqueIdentifier;
    dataFrameDict[@"data"] = data.copy;
    return dataFrameDict.copy;
}

- (void)addTask:(NSURLSessionTask *)task data:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error toRecordingEditor:(BKRRecordingEditor *)editor {
    BKRRecordableRawFrame *originalRequestRawFrame = [BKRRecordableRawFrame frameWithTask:task];
    originalRequestRawFrame.item = task.originalRequest;
    [editor addFrame:originalRequestRawFrame];
    
    BKRRecordableRawFrame *currentRequestRawFrame = [BKRRecordableRawFrame frameWithTask:task];
    currentRequestRawFrame.item = task.currentRequest;
    [editor addFrame:currentRequestRawFrame];
    
    BKRRecordableRawFrame *responseRawFrame = [BKRRecordableRawFrame frameWithTask:task];
    responseRawFrame.item = response;
    [editor addFrame:responseRawFrame];
    
    BKRRecordableRawFrame *dataRawFrame = [BKRRecordableRawFrame frameWithTask:task];
    dataRawFrame.item = data;
    [editor addFrame:dataRawFrame];
}

- (NSArray *)framesArrayWithTask:(NSURLSessionTask *)task data:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error {
    NSMutableArray *frames = [NSMutableArray array];
    
    BKRPlayableRawFrame *originalRequestFrame = [BKRPlayableRawFrame frameWithTask:task];
    originalRequestFrame.item = task.originalRequest;
    [frames addObject:originalRequestFrame.editedFrame];
    
    BKRPlayableRawFrame *currentRequestFrame = [BKRPlayableRawFrame frameWithTask:task];
    currentRequestFrame.item = task.currentRequest;
    [frames addObject:currentRequestFrame.editedFrame];
    
    BKRPlayableRawFrame *responseFrame = [BKRPlayableRawFrame frameWithTask:task];
    responseFrame.item = response;
    [frames addObject:responseFrame.editedFrame];
    
    BKRPlayableRawFrame *dataFrame = [BKRPlayableRawFrame frameWithTask:task];
    dataFrame.item = data;
    [frames addObject:dataFrame.editedFrame];
    
    return frames.copy;
}

- (void)assertFramesOrder:(BKRScene *)scene extraAssertions:(void (^)(BKRScene *))assertions {
    NSDate *lastDate = [NSDate dateWithTimeIntervalSince1970:0];
    for (BKRFrame *frame in scene.allFrames) {
        XCTAssertEqual([lastDate compare:frame.creationDate], NSOrderedAscending);
        lastDate = frame.creationDate;
    }
    if (assertions) {
        assertions(scene);
    }
}

- (void)assertRequest:(BKRRequestFrame *)request withRequest:(NSURLRequest *)otherRequest extraAssertions:(void (^)(BKRRequestFrame *, NSURLRequest *))assertions {
    XCTAssertNotNil(request);
    XCTAssertNotNil(otherRequest);
    XCTAssertEqual(request.HTTPShouldHandleCookies, otherRequest.HTTPShouldHandleCookies);
    XCTAssertEqual(request.HTTPShouldUsePipelining, otherRequest.HTTPShouldUsePipelining);
//    NSLog(@"request: %@", request.allHTTPHeaderFields);
//    NSLog(@"otherRequest: %@", otherRequest.allHTTPHeaderFields);
    XCTAssertEqualObjects(request.allHTTPHeaderFields, otherRequest.allHTTPHeaderFields);
//    if (request.allHTTPHeaderFields.allKeys.count) {
//        NSLog(@"%d", [request.allHTTPHeaderFields.allKeys.firstObject isEqual:otherRequest.allHTTPHeaderFields.allKeys.firstObject]);
//        NSLog(@"%d", [request.allHTTPHeaderFields.allValues.firstObject isEqual:otherRequest.allHTTPHeaderFields.allValues.firstObject]);
//    }
    XCTAssertEqualObjects(request.URL, otherRequest.URL);
    XCTAssertEqual(request.timeoutInterval, otherRequest.timeoutInterval);
    XCTAssertEqualObjects(request.HTTPMethod, otherRequest.HTTPMethod);
    XCTAssertEqual(request.allowsCellularAccess, otherRequest.allowsCellularAccess);
    if (assertions) {
        assertions(request, otherRequest);
    }
}

- (void)assertResponse:(BKRResponseFrame *)response withResponse:(NSURLResponse *)otherResponse extraAssertions:(void (^)(BKRResponseFrame *, NSURLResponse *))assertions {
    XCTAssertNotNil(response);
    XCTAssertNotNil(otherResponse);
    if ([otherResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *castedDataTaskResponse = (NSHTTPURLResponse *)otherResponse;
        XCTAssertEqualObjects(response.allHeaderFields, castedDataTaskResponse.allHeaderFields);
        XCTAssertEqual(response.statusCode, castedDataTaskResponse.statusCode);
    }
    if (assertions) {
        assertions(response, otherResponse);
    }
}

- (void)assertData:(BKRDataFrame *)data withData:(NSData *)otherData extraAssertions:(void (^)(BKRDataFrame *, NSData *))assertions {
    XCTAssertNotNil(data);
    XCTAssertNotNil(otherData);
    XCTAssertNotNil(data.rawData);
    XCTAssertEqualObjects(data.rawData, otherData);
    if (assertions) {
        assertions(data, otherData);
    }
}

- (void)assertErrorFrame:(BKRErrorFrame *)errorFrame withError:(NSError *)otherError extraAssertions:(void (^)(BKRErrorFrame *, NSError *))assertions {
    XCTAssertNotNil(errorFrame);
    XCTAssertNotNil(otherError);
    XCTAssertEqual(errorFrame.code, otherError.code);
    XCTAssertEqualObjects(errorFrame.domain, otherError.domain);
    // skipping the userInfo for now until I fix the error recording
    if (errorFrame.userInfo || otherError.userInfo) {
        XCTAssertEqualObjects(errorFrame.userInfo, otherError.userInfo);
    }
}

- (void)assertRequest:(BKRRequestFrame *)request withRequestDict:(NSDictionary *)otherRequest extraAssertions:(void (^)(BKRRequestFrame *request, NSDictionary *otherRequest))assertions {
    [self _assertFrame:request withDict:otherRequest];
    XCTAssertEqualObjects(request.URL.absoluteString, otherRequest[@"URL"]);
    XCTAssertEqual(request.timeoutInterval, [otherRequest[@"timeoutInterval"] doubleValue]);
    XCTAssertEqual(request.allowsCellularAccess, [otherRequest[@"allowsCellularAccess"] boolValue]);
    XCTAssertEqual(request.HTTPShouldUsePipelining, [otherRequest[@"HTTPShouldUsePipelining"] boolValue]);
    XCTAssertEqual(request.HTTPShouldHandleCookies, [otherRequest[@"HTTPShouldHandleCookies"] boolValue]);
    if (request.HTTPMethod) {
        XCTAssertEqualObjects(request.HTTPMethod, otherRequest[@"HTTPMethod"]);
    } else {
        XCTAssertNil(otherRequest[@"HTTPMethod"]);
    }
    if (request.HTTPBody) {
        XCTAssertEqualObjects(request.HTTPBody, otherRequest[@"HTTPBody"]);
    } else {
        XCTAssertNil(otherRequest[@"HTTPBody"]);
    }
    if (request.allHTTPHeaderFields) {
        XCTAssertEqualObjects(request.allHTTPHeaderFields, otherRequest[@"allHTTPHeaderFields"]);
    } else {
        XCTAssertNil(otherRequest[@"allHTTPHeaderFields"]);
    }
    if (assertions) {
        assertions(request, otherRequest);
    }
}

- (void)assertResponse:(BKRResponseFrame *)response withResponseDict:(NSDictionary *)otherResponse extraAssertions:(void (^)(BKRResponseFrame *response, NSDictionary *otherResponse))assertions {
    [self _assertFrame:response withDict:otherResponse];
    XCTAssertEqualObjects(response.URL.absoluteString, otherResponse[@"URL"]);
    XCTAssertEqualObjects(response.MIMEType, otherResponse[@"MIMEType"]);
    if (response.statusCode >= 0) {
        XCTAssertEqual(response.statusCode, [otherResponse[@"statusCode"] integerValue]);
        XCTAssertEqualObjects(response.allHeaderFields, otherResponse[@"allHeaderFields"]);
    } else {
        XCTAssertNil(otherResponse[@"statusCode"]);
        XCTAssertNil(otherResponse[@"allHeaderFields"]);
    }
    if (assertions) {
        assertions(response, otherResponse);
    }
}

- (void)assertData:(BKRDataFrame *)data withDataDict:(NSDictionary *)otherData extraAssertions:(void (^)(BKRDataFrame *data, NSDictionary *otherData))assertions {
    [self _assertFrame:data withDict:otherData];
    XCTAssertEqualObjects(data.rawData, otherData[@"data"]);
    
    if (assertions) {
        assertions(data, otherData);
    }
}

- (void)_assertFrame:(BKRFrame *)frame withDict:(NSDictionary *)frameDict {
    XCTAssertEqualObjects(NSStringFromClass(frame.class), frameDict[@"class"]);
    XCTAssertEqualObjects(frame.creationDate, frameDict[@"creationDate"]);
    XCTAssertEqualObjects(frame.uniqueIdentifier, frameDict[@"uniqueIdentifier"]);
}

- (NSTimeInterval)unixTimestampForPubNubTimetoken:(NSNumber *)timetoken {
    NSTimeInterval rawTimetoken = [timetoken doubleValue];
    return rawTimetoken/pow(10, 7);
}

- (double)timeIntervalForCurrentUnixTimestamp {
    NSTimeInterval currentUnixTimestamp = [[NSDate date] timeIntervalSince1970];
    return currentUnixTimestamp;
}

#pragma mark - HTTPBin helpers

// TODO: implement content length at some point
- (BKRExpectedScenePlistDictionaryBuilder *)standardGETRequestDictionaryBuilderForHTTPBinWithQueryItemString:(NSString *)queryItemString contentLength:(NSString *)contentLength {
    NSString *taskUniqueIdentifier = [NSUUID UUID].UUIDString;
    BKRExpectedScenePlistDictionaryBuilder *sceneBuilder = [BKRExpectedScenePlistDictionaryBuilder builder];
    NSString *finalQueryItemString = nil;
    NSMutableDictionary *argsDict = nil;
    if (queryItemString) {
        finalQueryItemString = [@"?" stringByAppendingString:queryItemString];
        NSURLComponents *components = [NSURLComponents componentsWithString:finalQueryItemString];
        NSArray<NSURLQueryItem *> *queryItems = [components queryItems];
        argsDict = [NSMutableDictionary dictionary];
        for (NSURLQueryItem *item in queryItems) {
            argsDict[item.name] = item.value;
        }
    }
    sceneBuilder.URLString = [NSString stringWithFormat:@"https://httpbin.org/get%@", (finalQueryItemString ? finalQueryItemString : @"")];
    sceneBuilder.taskUniqueIdentifier = taskUniqueIdentifier;
    //    sceneBuilder.currentRequestAllHTTPHeaderFields = @{
    //                                                       @"Accept": @"*/*",
    //                                                       @"Accept-Encoding": @"gzip, deflate",
    //                                                       @"Accept-Language": @"en-us"
    //                                                       };
    sceneBuilder.currentRequestAllHTTPHeaderFields = @{};
    NSMutableDictionary *receivedJSON = [@{
                                           @"args": @{},
                                           @"headers": @{
                                                   @"Accept": @"*/*",
                                                   @"Accept-Encoding": @"gzip, deflate",
                                                   @"Accept-Language": @"en-us",
                                                   @"Host": @"httpbin.org",
                                                   @"User-Agent": @"xctest (unknown version) CFNetwork/758.2.8 Darwin/15.3.0"
                                                   },
                                           @"origin": @"198.0.209.238",
                                           @"url": sceneBuilder.URLString
                                           } mutableCopy];
    if (argsDict) {
        receivedJSON[@"args"] = argsDict.copy;
    }
    sceneBuilder.receivedJSON = receivedJSON.copy;
    sceneBuilder.responseAllHeaderFields = @{
                                             @"Access-Control-Allow-Origin": @"*",
                                             @"Content-Length": @"338",
                                             @"Content-Type": @"application/json",
                                             @"Date": @"Fri, 22 Jan 2016 20:36:26 GMT",
                                             @"Server": @"nginx",
                                             @"access-control-allow-credentials": @"true"
                                             };
    return sceneBuilder;
}

- (BKRExpectedScenePlistDictionaryBuilder *)standardPOSTRequestDictionaryBuilderForHTTPBin {
    NSString *taskUniqueIdentifer = [NSUUID UUID].UUIDString;
    BKRExpectedScenePlistDictionaryBuilder *sceneBuilder = [BKRExpectedScenePlistDictionaryBuilder builder];
    sceneBuilder.URLString = @"https://httpbin.org/post";
    sceneBuilder.taskUniqueIdentifier = taskUniqueIdentifer;
    sceneBuilder.originalRequestAllHTTPHeaderFields = @{};
    sceneBuilder.HTTPMethod = @"POST";
    return sceneBuilder;
}

- (void)assertCreationOfPlayableCassetteWithNumberOfScenes:(NSUInteger)numberOfScenes {
    NSParameterAssert(numberOfScenes);
    NSMutableArray<BKRExpectedScenePlistDictionaryBuilder *> *sceneBuilders = [NSMutableArray array];
    for (NSUInteger i=0; i < numberOfScenes; i++) {
        NSString *queryString = [NSString stringWithFormat:@"scene=%ld", (long)i];
        BKRExpectedScenePlistDictionaryBuilder *sceneBuilder = [self standardGETRequestDictionaryBuilderForHTTPBinWithQueryItemString:queryString contentLength:nil];
        XCTAssertNotNil(sceneBuilder);
        [sceneBuilders addObject:sceneBuilder];
    }
    XCTAssertEqual(sceneBuilders.count, numberOfScenes);
    NSDictionary *cassetteDictionary = [self expectedCassetteDictionaryWithSceneBuilders:sceneBuilders.copy];
    XCTAssertNotNil(cassetteDictionary);
    BKRPlayableCassette *cassette = [[BKRPlayableCassette alloc] initFromPlistDictionary:cassetteDictionary];
    XCTAssertNotNil(cassette);
    XCTAssertEqual(cassette.allScenes.count, numberOfScenes);
}

- (void)testPlayingRequestForExpectedSceneBuilder:(BKRExpectedScenePlistDictionaryBuilder *)sceneBuilder {
    
}

- (void)setWithExpectationsPlayableCassette:(BKRPlayableCassette *)cassette inPlayer:(BKRPlayer *)player {
    __block XCTestExpectation *stubsExpectation;
    player.beforeAddingStubsBlock = ^void(void) {
        stubsExpectation = [self expectationWithDescription:@"setting up stubs"];
    };
    player.afterAddingStubsBlock = ^void(void) {
        [stubsExpectation fulfill];
    };
    player.currentCassette = cassette;
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

@end
