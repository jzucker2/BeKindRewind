//
//  XCTestCase+BKRAdditions.h
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/19/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <XCTest/XCTest.h>

typedef void (^taskCompletionHandler)(NSData *data, NSURLResponse *response, NSError *error);
typedef void (^taskTimeoutCompletionHandler)(NSURLSessionTask *task, NSError *error);

@class BKRRequestFrame, BKRResponseFrame, BKRDataFrame;
@interface XCTestCase (BKRAdditions)

- (void)getTaskWithURLString:(NSString *)URLString taskCompletionAssertions:(taskCompletionHandler)taskCompletionHandler taskTimeoutAssertions:(taskTimeoutCompletionHandler)taskTimeoutHandler;

- (void)assertRequest:(BKRRequestFrame *)request withRequest:(NSURLRequest *)otherRequest extraAssertions:(void (^)(BKRRequestFrame *request, NSURLRequest *otherRequest))assertions;
- (void)assertResponse:(BKRResponseFrame *)response withResponse:(NSURLResponse *)otherResponse extraAssertions:(void (^)(BKRResponseFrame *response, NSURLResponse *otherResponse))assertions;
- (void)assertData:(BKRDataFrame *)data withData:(NSData *)otherData extraAssertions:(void (^)(BKRDataFrame *data, NSData *otherData))assertions;

@end
