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
        BKRScene *scene = item.scene;
        NSDictionary *options = [self requestComparisonOptions];
#warning update matcher
        // try to match final request first
        if (
            [request BKR_isEquivalentToRequestFrame:scene.originalRequest options:options] &&
            !item.redirectsRemaining
            ) {
            responseStub = scene.finalResponseStub;
        } else if (item.redirectsRemaining) {
            // else match redirects if we still expect some
            BKRRedirectFrame *redirectFrame = [scene redirectFrameForRemainingRedirect:item.redirectsRemaining];
            if ([request BKR_isEquivalentToRequestFrame:redirectFrame.requestFrame options:options]) {
                responseStub = [scene responseStubForRedirectFrame:redirectFrame];
            }
        }
    }
    return responseStub;
}

- (NSDictionary *)requestComparisonOptions {
    return @{
             kBKRShouldIgnoreQueryItemsOrder: @YES,
             };
}

//// should also handle current request for everything, not just comparing to original request ?

@end
