//
//  BKRTestVCR.m
//  Pods
//
//  Created by Jordan Zucker on 2/7/16.
//
//

#import <XCTest/XCTest.h>
#import "BKRPlayheadMatcher.h" // remove this
#import "BKRTestVCR.h"

@interface BKRTestVCR ()

@end

@implementation BKRTestVCR
@synthesize currentTestCase = _currentTestCase;

#pragma mark - BKRTestVCRActions

- (instancetype)initWithTestCase:(XCTestCase *)testCase {
    self = [super initWithMatcherClass:[BKRPlayheadMatcher class] andEmptyCassetteSavingOption:NO];
    if (self) {
        _currentTestCase = testCase;
    }
    return self;
}

+ (instancetype)vcrWithTestCase:(XCTestCase *)testCase {
    return [[self alloc] initWithTestCase:testCase];
}

- (void)record {
    
}

- (void)pause {
    
}

- (void)play {
    
}

- (void)stop {
    
}

- (void)reset {
    
}

- (BOOL)insert:(BKRTestVCRCassetteLoadingBlock)cassetteLoadingBlock {
    return NO;
}

- (BOOL)eject:(BKRTestVCRCassetteSavingBlock)cassetteSavingBlock {
    return NO;
}



@end
