//
//  BKROHHTTPStubsWrapper.m
//  Pods
//
//  Created by Jordan Zucker on 1/24/16.
//
//

#import <OHHTTPStubs/OHHTTPStubs.h>
#import "BKROHHTTPStubsWrapper.h"

@implementation BKROHHTTPStubsWrapper

+ (void)removeAllStubs {
    [OHHTTPStubs removeAllStubs];
}

@end
