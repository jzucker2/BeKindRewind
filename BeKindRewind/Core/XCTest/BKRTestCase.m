//
//  BKRTestCase.m
//  Pods
//
//  Created by Jordan Zucker on 1/26/16.
//
//

#import "BKRVCR.h"
#import "BKRTestCase.h"
#import "BKRPlayheadMatcher.h"

@interface BKRTestCase ()
@property (nonatomic) BKRVCR *vcr;
@end

@implementation BKRTestCase

- (BOOL)isRecording {
    return YES;
}

- (Class<BKRRequestMatching>)matcherClass {
    return [BKRPlayheadMatcher class];
}

- (instancetype)initWithInvocation:(NSInvocation *)invocation {
    self = [super initWithInvocation:invocation];
    if (self) {
//        _vcr = [BKRVCR vcrWithCassette:nil];
//        _vcr.recording = [self isRecording];
    }
    return self;
}

- (void)setUp {
    [super setUp];
//    self.vcr.recording = [self isRecording];
}

@end
