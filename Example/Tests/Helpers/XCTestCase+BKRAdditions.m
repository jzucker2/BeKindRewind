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
#import <BeKindRewind/BKRRecordableRawFrame.h>
#import <BeKindRewind/BKRRecordableCassette.h>

@implementation XCTestCase (BKRAdditions)

- (void)getTaskWithURLString:(NSString *)URLString taskCompletionAssertions:(taskCompletionHandler)taskCompletionHandler taskTimeoutAssertions:(taskTimeoutCompletionHandler)taskTimeoutHandler {
    __block XCTestExpectation *basicGetExpectation = [self expectationWithDescription:@"basicGetExpectation"];
    NSURL *basicGetURL = [NSURL URLWithString:URLString];
    NSURLRequest *basicGetRequest = [NSURLRequest requestWithURL:basicGetURL];
    __block NSURLSessionDataTask *basicGetTask = [[NSURLSession sharedSession] dataTaskWithRequest:basicGetRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(error);
        if (taskCompletionHandler) {
            taskCompletionHandler(basicGetTask, data, response, error);
        }
        [basicGetExpectation fulfill];
        basicGetExpectation = nil;
    }];
    XCTAssertEqual(basicGetTask.state, NSURLSessionTaskStateSuspended);
    [basicGetTask resume];
    XCTAssertEqual(basicGetTask.state, NSURLSessionTaskStateRunning);
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertEqual(basicGetTask.state, NSURLSessionTaskStateCompleted);
        XCTAssertNotNil(basicGetTask.originalRequest);
        XCTAssertNotNil(basicGetTask.currentRequest);
        if (taskTimeoutHandler) {
            taskTimeoutHandler(basicGetTask, error);
        }
    }];
}

- (void)post:(NSData *)postData withURLString:(NSString *)URLString taskCompletionAssertions:(taskCompletionHandler)taskCompletionHandler taskTimeoutAssertions:(taskTimeoutCompletionHandler)taskTimeoutHandler {
    __block XCTestExpectation *basicPostExpectation = [self expectationWithDescription:@"basicPostExpectation"];
    NSURL *basicPostURL = [NSURL URLWithString:URLString];
    NSMutableURLRequest *basicPostRequest = [NSMutableURLRequest requestWithURL:basicPostURL];
    basicPostRequest.HTTPMethod = @"POST";
    basicPostRequest.HTTPBody = postData;
    __block NSURLSessionDataTask *basicPostTask = [[NSURLSession sharedSession] dataTaskWithRequest:basicPostRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(error);
        if (taskCompletionHandler) {
            taskCompletionHandler(basicPostTask, data, response, error);
        }
        [basicPostExpectation fulfill];
        basicPostExpectation = nil;
    }];
    XCTAssertEqual(basicPostTask.state, NSURLSessionTaskStateSuspended);
    [basicPostTask resume];
    XCTAssertEqual(basicPostTask.state, NSURLSessionTaskStateRunning);
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertEqual(basicPostTask.state, NSURLSessionTaskStateCompleted);
        XCTAssertNotNil(basicPostTask.originalRequest);
        XCTAssertNotNil(basicPostTask.currentRequest);
        if (taskTimeoutHandler) {
            taskTimeoutHandler(basicPostTask, error);
        }
    }];
}

- (void)addTask:(NSURLSessionTask *)task data:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error toCassette:(BKRRecordableCassette *)cassette {
    BKRRecordableRawFrame *dataRawFrame = [BKRRecordableRawFrame frameWithTask:task];
    dataRawFrame.item = data;
    [cassette addFrame:dataRawFrame];
    
    BKRRecordableRawFrame *originalRequestRawFrame = [BKRRecordableRawFrame frameWithTask:task];
    originalRequestRawFrame.item = task.originalRequest;
    [cassette addFrame:originalRequestRawFrame];
    
    BKRRecordableRawFrame *currentRequestRawFrame = [BKRRecordableRawFrame frameWithTask:task];
    currentRequestRawFrame.item = task.currentRequest;
    [cassette addFrame:currentRequestRawFrame];
    
    BKRRecordableRawFrame *responseRawFrame = [BKRRecordableRawFrame frameWithTask:task];
    responseRawFrame.item = response;
    [cassette addFrame:responseRawFrame];
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
    XCTAssertEqualObjects(request.allHTTPHeaderFields, otherRequest.allHTTPHeaderFields);
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

@end
