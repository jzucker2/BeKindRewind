//
//  BKRPlayheadMatcher.m
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import "BKRPlayheadMatcher.h"

@implementation BKRPlayheadMatcher

+ (id<BKRRequestMatching>)matcher {
    return [[self alloc] init];
}

- (BOOL)hasMatchForRequest:(NSURLRequest *)request withPlayhead:(BKRPlayhead *)playhead {
    return ([self matchForRequest:request withPlayhead:playhead] != nil);
}

- (BKRResponseStub *)matchForRequest:(NSURLRequest *)request withPlayhead:(BKRPlayhead *)playhead {
    BKRResponseStub *responseStub = nil;
    for (BKRPlayheadItem *item in playhead.incompleteItems) {
        NSLog(@"item: %@", item);
        BKRScene *scene = item.scene;
        if ([scene hasResponseForRequest:request]) {
            if (
                item.redirectsRemaining &&
                [scene hasRedirectResponseStubForRemainingRequest:request]
                ) {
                responseStub = [scene responseStubForRemainingRedirect:item.redirectsRemaining];
            } else if ([scene hasFinalResponseStubForRequest:request]) {
                responseStub = [scene finalResponseStub];
            }
        }
    }
    return responseStub;
}

//// should also handle current request for everything, not just comparing to original request

@end
