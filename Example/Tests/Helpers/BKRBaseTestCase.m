//
//  BKRBaseTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/24/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKROHHTTPStubsWrapper.h>
#import "BKRBaseTestCase.h"

@implementation BKRBaseTestCase

- (void)setUp {
    [super setUp];
    if(getenv("NSZombieEnabled") || getenv("NSAutoreleaseFreedObjectCheckEnabled")) {
        NSLog(@"NSZombieEnabled/NSAutoreleaseFreedObjectCheckEnabled enabled!");
    } else {
        NSLog(@"all clean");
    }
    [BKROHHTTPStubsWrapper removeAllStubs];
}

- (void)tearDown {
    [BKROHHTTPStubsWrapper removeAllStubs];
    [super tearDown];
}

@end
