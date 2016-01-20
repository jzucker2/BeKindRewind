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

- (void)assertRequest:(BKRRequest *)request withRequest:(NSURLRequest *)otherRequest extraAssertions:(void (^)(BKRRequest *, NSURLRequest *))assertions {
    XCTAssertNotNil(request);
    XCTAssertNotNil(otherRequest);
    
    if (assertions) {
        assertions(request, otherRequest);
    }
}

- (void)assertResponse:(BKRResponse *)response withResponse:(NSURLResponse *)otherResponse extraAssertions:(void (^)(BKRResponse *, NSURLResponse *))assertions {
    XCTAssertNotNil(response);
    XCTAssertNotNil(otherResponse);
//    XCTAssertEqual(response.statusCode, 200);
//    NSHTTPURLResponse *castedDataTaskResponse = (NSHTTPURLResponse *)response;
//    XCTAssertEqualObjects(responseFrame.allHeaderFields, castedDataTaskResponse.allHeaderFields);
//    XCTAssertEqual(responseFrame.statusCode, castedDataTaskResponse.statusCode);
    if (assertions) {
        assertions(response, otherResponse);
    }
}

- (void)assertData:(BKRData *)data withData:(NSData *)otherData extraAssertions:(void (^)(BKRData *, NSData *))assertions {
    XCTAssertNotNil(data);
    XCTAssertNotNil(otherData);
    if (assertions) {
        assertions(data, otherData);
    }
}

@end
