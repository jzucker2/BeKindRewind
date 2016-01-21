//
//  XCTestCase+BKRAdditions.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/19/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import "XCTestCase+BKRAdditions.h"
#import <BeKindRewind/BKRDataFrame.h>
#import <BeKindRewind/BKRRequestFrame.h>
#import <BeKindRewind/BKRResponseFrame.h>

@implementation XCTestCase (BKRAdditions)

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

@end
