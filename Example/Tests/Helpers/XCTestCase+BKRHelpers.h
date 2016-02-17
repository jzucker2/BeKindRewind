//
//  XCTestCase+BKRHelpers.h
//  BeKindRewind
//
//  Created by Jordan Zucker on 2/16/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface BKRTestExpectedResult : NSObject
@property (nonatomic, copy) NSString *URLString;
@property (nonatomic, copy) NSString *HTTPMethod; // nil by default
@property (nonatomic, assign) BOOL shouldCancel; // no by default
@property (nonatomic, strong) NSDictionary *HTTPBodyJSON;
@property (nonatomic, copy) NSString *taskUniqueIdentifier;
@property (nonatomic, strong) NSData *HTTPBody;
@property (nonatomic, strong) NSData *receivedData;
@property (nonatomic, strong) NSDictionary *receivedJSON;
@property (nonatomic, assign) BOOL hasResponse;
@property (nonatomic, assign) NSInteger errorCode;
@property (nonatomic, strong) NSDictionary *errorUserInfo;
@property (nonatomic, copy) NSString *errorDomain;
@property (nonatomic, assign) NSInteger responseCode;
@property (nonatomic, assign) NSInteger expectedSceneNumber;
@property (nonatomic, assign) NSInteger expectedNumberOfFrames;
+ (instancetype)result;
@end

typedef void (^BKRTestNetworkCompletionHandler)(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error);
typedef void (^BKRTestNetworkTimeoutCompletionHandler)(NSURLSessionTask *task, NSError *error);

typedef void (^BKRTestBatchNetworkCompletionHandler)(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error);
typedef void (^BKRTestBatchNetworkTimeoutCompletionHandler)(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error);

@class BKRScene, BKRPlayer, BKRCassette;
@interface XCTestCase (BKRHelpers)

- (void)BKRTest_executeNetworkCallsForExpectedResults:(NSArray<BKRTestExpectedResult *> *)expectedResults withTaskCompletionAssertions:(BKRTestBatchNetworkCompletionHandler)networkCompletionAssertions taskTimeoutHandler:(BKRTestBatchNetworkTimeoutCompletionHandler)timeoutAssertions;

- (void)BKRTest_executeNetworkCallWithExpectedResult:(BKRTestExpectedResult *)expectedResult withTaskCompletionAssertions:(BKRTestNetworkCompletionHandler)networkCompletionAssertions taskTimeoutHandler:(BKRTestNetworkTimeoutCompletionHandler)timeoutAssertions;

- (void)BKRTest_executeHTTPBinNetworkCallsForExpectedResults:(NSArray<BKRTestExpectedResult *> *)expectedResults withTaskCompletionAssertions:(BKRTestBatchNetworkCompletionHandler)networkCompletionAssertions taskTimeoutHandler:(BKRTestBatchNetworkTimeoutCompletionHandler)timeoutAssertions;

- (void)assertFramesOrderForScene:(BKRScene *)scene;

- (BKRCassette *)cassetteFromExpectedResults:(NSArray<BKRTestExpectedResult *> *)expectedResults;

- (void)setRecorderToEnabledWithExpectation:(BOOL)enabled;
- (void)setPlayer:(BKRPlayer *)player toEnabledWithExpectation:(BOOL)enabled;
- (void)setRecorderBeginAndEndRecordingBlocks;

#pragma mark - Plist builders

- (NSMutableDictionary *)standardRequestDictionary;
- (NSMutableDictionary *)standardResponseDictionary;
- (NSMutableDictionary *)standardDataDictionary;
- (NSMutableDictionary *)standardErrorDictionary;

#pragma mark - HTTPBin helpers

//- (void)BKRTest_executeHTTPBinNetworkCallWithExpectedResult:(BKRTestExpectedResult *)expectedResult withTaskCompletionAssertions:(BKRTestNetworkCompletionHandler)networkCompletionAssertions taskTimeoutHandler:(BKRTestNetworkTimeoutCompletionHandler)timeoutAssertions;

- (BKRTestExpectedResult *)HTTPBinCancelledRequest;
- (BKRTestExpectedResult *)HTTPBinGetRequestWithQueryString:(NSString *)queryString;
- (BKRTestExpectedResult *)HTTPBinPostRequest;

@end
