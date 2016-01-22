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

@interface BKRExpectedData : NSObject
@property (nonatomic, copy) NSData *data;
@property (nonatomic, copy) NSURLResponse *response;
@end

@class BKRRequestFrame, BKRResponseFrame, BKRDataFrame, BKRScene, BKRRecordableCassette;
@interface XCTestCase (BKRAdditions)

- (void)getTaskWithURLString:(NSString *)URLString taskCompletionAssertions:(taskCompletionHandler)taskCompletionHandler taskTimeoutAssertions:(taskTimeoutCompletionHandler)taskTimeoutHandler;
- (void)post:(NSData *)postData withURLString:(NSString *)URLString taskCompletionAssertions:(taskCompletionHandler)taskCompletionHandler taskTimeoutAssertions:(taskTimeoutCompletionHandler)taskTimeoutHandler;

- (void)addTask:(NSURLSessionTask *)task data:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error toCassette:(BKRRecordableCassette *)cassette;

- (void)assertFramesOrder:(BKRScene *)scene extraAssertions:(void (^)(BKRScene *scene))assertions;

- (void)assertRequest:(BKRRequestFrame *)request withRequest:(NSURLRequest *)otherRequest extraAssertions:(void (^)(BKRRequestFrame *request, NSURLRequest *otherRequest))assertions;
- (void)assertResponse:(BKRResponseFrame *)response withResponse:(NSURLResponse *)otherResponse extraAssertions:(void (^)(BKRResponseFrame *response, NSURLResponse *otherResponse))assertions;
- (void)assertData:(BKRDataFrame *)data withData:(NSData *)otherData extraAssertions:(void (^)(BKRDataFrame *data, NSData *otherData))assertions;

- (void)assertRequest:(BKRRequestFrame *)request withRequestDict:(NSDictionary *)otherRequest extraAssertions:(void (^)(BKRRequestFrame *request, NSDictionary *otherRequest))assertions;
- (void)assertResponse:(BKRResponseFrame *)response withResponseDict:(NSDictionary *)otherResponse extraAssertions:(void (^)(BKRResponseFrame *response, NSDictionary *otherResponse))assertions;
- (void)assertData:(BKRDataFrame *)data withDataDict:(NSDictionary *)otherData extraAssertions:(void (^)(BKRDataFrame *data, NSDictionary *otherData))assertions;

@end
