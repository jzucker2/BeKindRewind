//
//  BKRVCR.m
//  Pods
//
//  Created by Jordan Zucker on 1/19/16.
//
//

#import "BKRVCR.h"
#import "BKRCassette.h"
#import "BKRNSURLSessionConnection.h"

@interface BKRVCR ()

@end

@implementation BKRVCR

- (instancetype)initWithCassette:(BKRCassette *)cassette {
    self = [super init];
    if (self) {
        _currentCassette = cassette;
    }
    return self;
}

+ (instancetype)vcrWithCassette:(BKRCassette *)cassette {
    return [[self alloc] initWithCassette:cassette];
}

- (void)swizzleNetworkCallsForRecording {
    [BKRNSURLSessionConnection swizzleNSURLSessionClasses];
}

@end
