//
//  XCTestCase+BKRAdditions.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/19/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import "XCTestCase+BKRAdditions.h"
#import <BeKindRewind/BKRData.h>
#import <BeKindRewind/BKRRequest.h>
#import <BeKindRewind/BKRResponse.h>

@implementation XCTestCase (BKRAdditions)

- (void)assertRequest:(BKRRequest *)request withRequest:(NSURLRequest *)otherRequest extraAssertions:(void (^)(BKRRequest *, NSURLRequest *))assertions {
    
}

- (void)assertResponse:(BKRResponse *)response withResponse:(NSURLResponse *)otherResponse extraAssertions:(void (^)(BKRResponse *, NSURLResponse *))assertions {
    
}

- (void)assertData:(BKRData *)data withData:(NSData *)otherData extraAssertions:(void (^)(BKRData *, NSData *))assertions {
    
}

@end
