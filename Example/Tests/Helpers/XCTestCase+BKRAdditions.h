//
//  XCTestCase+BKRAdditions.h
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/19/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <XCTest/XCTest.h>

typedef void (^taskCompletionHandler)(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error);
typedef void (^taskTimeoutCompletionHandler)(NSURLSessionTask *task, NSError *error);

@interface BKRExpectedScenePlistDictionaryBuilder : NSObject
@property (nonatomic, copy) NSString *URLString;
@property (nonatomic, copy) NSString *taskUniqueIdentifier;
@property (nonatomic, copy) NSString *HTTPMethod;
@property (nonatomic, strong) id sentJSON;
@property (nonatomic, strong) id receivedJSON;
@property (nonatomic) BOOL hasCurrentRequest;
@property (nonatomic) BOOL hasResponse;
@property (nonatomic) NSInteger errorCode; // code and domain are required for this object to have an error frame
@property (nonatomic) NSDictionary *errorUserInfo; // optional
@property (nonatomic) NSString *errorDomain; // code and domain are required for this object to have an error frame
@property (nonatomic, strong) NSDictionary *originalRequestAllHTTPHeaderFields;
@property (nonatomic, strong) NSDictionary *currentRequestAllHTTPHeaderFields;
@property (nonatomic, strong) NSDictionary *responseAllHeaderFields;
+ (instancetype)builder;
@end

@class BKRRequestFrame, BKRResponseFrame, BKRDataFrame, BKRScene, BKRRecordableCassette, BKRPlayableCassette, BKRErrorFrame;
@interface XCTestCase (BKRAdditions)

- (void)getTaskWithURLString:(NSString *)URLString taskCompletionAssertions:(taskCompletionHandler)taskCompletionHandler taskTimeoutAssertions:(taskTimeoutCompletionHandler)taskTimeoutHandler;
- (void)cancellingGetTaskWithURLString:(NSString *)URLString taskCompletionAssertions:(taskCompletionHandler)taskCompletionHandler taskTimeoutAssertions:(taskTimeoutCompletionHandler)taskTimeoutHandler;
- (void)post:(NSData *)postData withURLString:(NSString *)URLString taskCompletionAssertions:(taskCompletionHandler)taskCompletionHandler taskTimeoutAssertions:(taskTimeoutCompletionHandler)taskTimeoutHandler;
- (void)postJSON:(id)JSON withURLString:(NSString *)URLString taskCompletionAssertions:(taskCompletionHandler)taskCompletionHandler taskTimeoutAssertions:(taskTimeoutCompletionHandler)taskTimeoutHandler;

- (void)addTask:(NSURLSessionTask *)task data:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error toRecordableCassette:(BKRRecordableCassette *)cassette;
- (NSArray *)framesArrayWithTask:(NSURLSessionTask *)task data:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error;

// used for building
- (NSDictionary *)expectedCassetteDictionaryWithSceneBuilders:(NSArray<BKRExpectedScenePlistDictionaryBuilder *> *)expectedPlistBuilders;
- (NSDictionary *)expectedCassetteDictionaryWithCreationDate:(NSDate *)creationDate sceneDictionaries:(NSArray<NSDictionary *> *)sceneDictionaries; // use this because scenes have a weird format for storage
- (NSMutableDictionary *)standardRequestDictionary;
- (NSMutableDictionary *)standardResponseDictionary;
- (NSMutableDictionary *)standardDataDictionary;
- (NSMutableDictionary *)standardErrorDictionary;


- (NSDictionary *)dictionaryWithRequest:(NSURLRequest *)request forTask:(NSURLSessionTask *)task;
- (NSDictionary *)dictionaryWithData:(NSData *)data forTask:(NSURLSessionTask *)task;
- (NSDictionary *)dictionaryWithResponse:(NSURLResponse *)response forTask:(NSURLSessionTask *)task;

- (void)assertFramesOrder:(BKRScene *)scene extraAssertions:(void (^)(BKRScene *scene))assertions;

- (void)assertRequest:(BKRRequestFrame *)request withRequest:(NSURLRequest *)otherRequest extraAssertions:(void (^)(BKRRequestFrame *request, NSURLRequest *otherRequest))assertions;
- (void)assertResponse:(BKRResponseFrame *)response withResponse:(NSURLResponse *)otherResponse extraAssertions:(void (^)(BKRResponseFrame *response, NSURLResponse *otherResponse))assertions;
- (void)assertData:(BKRDataFrame *)data withData:(NSData *)otherData extraAssertions:(void (^)(BKRDataFrame *data, NSData *otherData))assertions;
- (void)assertErrorFrame:(BKRErrorFrame *)errorFrame withError:(NSError *)otherError extraAssertions:(void (^)(BKRErrorFrame *errorFrame, NSError *otherError))assertions;

- (void)assertRequest:(BKRRequestFrame *)request withRequestDict:(NSDictionary *)otherRequest extraAssertions:(void (^)(BKRRequestFrame *request, NSDictionary *otherRequest))assertions;
- (void)assertResponse:(BKRResponseFrame *)response withResponseDict:(NSDictionary *)otherResponse extraAssertions:(void (^)(BKRResponseFrame *response, NSDictionary *otherResponse))assertions;
- (void)assertData:(BKRDataFrame *)data withDataDict:(NSDictionary *)otherData extraAssertions:(void (^)(BKRDataFrame *data, NSDictionary *otherData))assertions;

@end
