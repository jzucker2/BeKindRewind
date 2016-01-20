//
//  XCTestCase+BKRAdditions.h
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/19/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <XCTest/XCTest.h>

@class BKRRequest, BKRResponse, BKRData;
@interface XCTestCase (BKRAdditions)

- (void)assertRequest:(BKRRequest *)request withRequest:(NSURLRequest *)otherRequest extraAssertions:(void (^)(BKRRequest *request, NSURLRequest *otherRequest))assertions;
- (void)assertResponse:(BKRResponse *)response withResponse:(NSURLResponse *)otherResponse extraAssertions:(void (^)(BKRResponse *response, NSURLResponse *otherResponse))assertions;
- (void)assertData:(BKRData *)data withData:(NSData *)otherData extraAssertions:(void (^)(BKRData *data, NSData *otherData))assertions;

@end
