//
//  BKRPlayheadWithTimingMatcher.m
//  Pods
//
//  Created by Jordan Zucker on 4/5/16.
//
//

#import "BKRPlayheadWithTimingMatcher.h"

@implementation BKRPlayheadWithTimingMatcher

#pragma mark - Optional

- (NSTimeInterval)requestTimeForRequest:(NSURLRequest *)request withStub:(BKRResponseStub *)responseStub {
    return 0;
}

- (NSTimeInterval)responseTimeForRequest:(NSURLRequest *)request withStub:(BKRResponseStub *)responseStub {
    return 0;
}

@end
