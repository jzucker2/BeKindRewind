//
//  XCTestCase+BKRHelpers.h
//  BeKindRewind
//
//  Created by Jordan Zucker on 2/16/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <BeKindRewind/BKRVCRActions.h>

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
@property (nonatomic, assign, readonly) BOOL hasError; // calculated by having errorCode and errorDomain
@property (nonatomic, assign) NSInteger errorCode;
@property (nonatomic, strong) NSDictionary *errorUserInfo;
@property (nonatomic, copy) NSString *errorDomain;
@property (nonatomic, assign) NSInteger responseCode; // if this is set, then hasResponse is automatically set to YES, expects responseAllHeaderFields to be set if this is set
@property (nonatomic, strong) NSDictionary *responseAllHeaderFields; // if this is set, then hasResponse is automatically set to YES, expects responseCode to be set if this is set
@property (nonatomic, assign) NSInteger expectedSceneNumber;
@property (nonatomic, assign) NSInteger expectedNumberOfFrames;
@property (nonatomic, assign) BOOL automaticallyAssignSceneNumberForAssertion; // YES by default
@property (nonatomic, assign) BOOL hasCurrentRequest; // default NO
@property (nonatomic, strong) NSDictionary *originalRequestAllHTTPHeaderFields;
@property (nonatomic, assign) BOOL isRecording; // no by default
@property (nonatomic, assign) BOOL shouldCompareCurrentRequestHTTPHeaderFields; // default is NO
@property (nonatomic, strong) NSDictionary *currentRequestAllHTTPHeaderFields; // setting this turns hasCurrentRequest to YES automatically
+ (instancetype)result;
@end

@class BKRScene;
typedef void (^BKRTestSceneAssertionHandler)(BKRScene *scene);
typedef void (^BKRTestBatchSceneAssertionHandler)(NSArray<BKRScene *> *scenes);

typedef void (^BKRTestNetworkCompletionHandler)(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error);
typedef void (^BKRTestNetworkTimeoutCompletionHandler)(NSURLSessionTask *task, NSError *error, BKRTestSceneAssertionHandler sceneAssertions);

typedef void (^BKRTestBatchNetworkCompletionHandler)(BKRTestExpectedResult *result, NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error);
typedef void (^BKRTestBatchNetworkTimeoutCompletionHandler)(BKRTestExpectedResult *result, NSURLSessionTask *task, NSError *error, BKRTestBatchSceneAssertionHandler batchSceneAssertions);

@class BKRPlayer, BKRCassette;
@interface XCTestCase (BKRHelpers)

- (void)BKRTest_executeNetworkCallsForExpectedResults:(NSArray<BKRTestExpectedResult *> *)expectedResults withTaskCompletionAssertions:(BKRTestBatchNetworkCompletionHandler)networkCompletionAssertions taskTimeoutHandler:(BKRTestBatchNetworkTimeoutCompletionHandler)timeoutAssertions;

- (void)BKRTest_executeNetworkCallWithExpectedResult:(BKRTestExpectedResult *)expectedResult withTaskCompletionAssertions:(BKRTestNetworkCompletionHandler)networkCompletionAssertions taskTimeoutHandler:(BKRTestNetworkTimeoutCompletionHandler)timeoutAssertions;

- (void)BKRTest_executeHTTPBinNetworkCallsForExpectedResults:(NSArray<BKRTestExpectedResult *> *)expectedResults withTaskCompletionAssertions:(BKRTestBatchNetworkCompletionHandler)networkCompletionAssertions taskTimeoutHandler:(BKRTestBatchNetworkTimeoutCompletionHandler)timeoutAssertions;

- (void)assertFramesOrderForScene:(BKRScene *)scene;

- (BKRCassette *)cassetteFromExpectedResults:(NSArray<BKRTestExpectedResult *> *)expectedResults;
- (BKRPlayer *)playerWithExpectedResults:(NSArray<BKRTestExpectedResult *> *)expectedResults;

- (void)setRecorderToEnabledWithExpectation:(BOOL)enabled;
- (void)setPlayer:(BKRPlayer *)player withExpectationToEnabled:(BOOL)enabled;
- (void)setRecorderBeginAndEndRecordingBlocks;

- (void)assertCassettePath:(NSString *)cassetteFilePath matchesExpectedResults:(NSArray<BKRTestExpectedResult *> *)expectedResults;

#pragma mark - VCR helpers

- (void)insertCassetteFilePath:(NSString *)cassetteFilePath intoVCR:(id<BKRVCRActions>)vcr;
- (void)resetVCR:(id<BKRVCRActions>)vcr;
- (BOOL)ejectCassetteFromVCR:(id<BKRVCRActions>)vcr; // returns result of eject message
- (void)playVCR:(id<BKRVCRActions>)vcr;
- (void)stopVCR:(id<BKRVCRActions>)vcr;
- (void)recordVCR:(id<BKRVCRActions>)vcr;
- (void)setVCRBeginAndEndRecordingBlocks:(id<BKRVCRRecording>)vcr;

#pragma mark - Plist builders

- (NSMutableDictionary *)standardRequestDictionary;
- (NSMutableDictionary *)standardResponseDictionary;
- (NSMutableDictionary *)standardDataDictionary;
- (NSMutableDictionary *)standardErrorDictionary;

#pragma mark - HTTPBin helpers

//- (void)BKRTest_executeHTTPBinNetworkCallWithExpectedResult:(BKRTestExpectedResult *)expectedResult withTaskCompletionAssertions:(BKRTestNetworkCompletionHandler)networkCompletionAssertions taskTimeoutHandler:(BKRTestNetworkTimeoutCompletionHandler)timeoutAssertions;

- (BKRTestExpectedResult *)HTTPBinCancelledRequestWithRecording:(BOOL)isRecording;
- (BKRTestExpectedResult *)HTTPBinGetRequestWithQueryString:(NSString *)queryString withRecording:(BOOL)isRecording;
- (BKRTestExpectedResult *)HTTPBinPostRequestWithRecording:(BOOL)isRecording;

@end
