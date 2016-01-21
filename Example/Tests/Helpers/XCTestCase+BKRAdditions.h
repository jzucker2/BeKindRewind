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

@class BKRRequestFrame, BKRResponseFrame, BKRDataFrame, BKRScene;
@interface XCTestCase (BKRAdditions)

- (void)getTaskWithURLString:(NSString *)URLString taskCompletionAssertions:(taskCompletionHandler)taskCompletionHandler taskTimeoutAssertions:(taskTimeoutCompletionHandler)taskTimeoutHandler;

- (void)assertFramesOrder:(BKRScene *)scene extraAssertions:(void (^)(BKRScene *scene))assertions;

- (void)assertRequest:(BKRRequestFrame *)request withRequest:(NSURLRequest *)otherRequest extraAssertions:(void (^)(BKRRequestFrame *request, NSURLRequest *otherRequest))assertions;
- (void)assertResponse:(BKRResponseFrame *)response withResponse:(NSURLResponse *)otherResponse extraAssertions:(void (^)(BKRResponseFrame *response, NSURLResponse *otherResponse))assertions;
- (void)assertData:(BKRDataFrame *)data withData:(NSData *)otherData extraAssertions:(void (^)(BKRDataFrame *data, NSData *otherData))assertions;

@end
