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
        // if there already is a finalResponseStub provided by this scene, then don't do anything with it
        if (item.hasFinalResponseStub) {
            // continue through loop
            continue;
        }
        BKRScene *scene = item.scene;
        NSDictionary *options = [self requestComparisonOptions];
        // try to match final request first
        BOOL matchesRequest = (
                               ([request BKR_isEquivalentToRequestFrame:scene.originalRequest options:options]) ||
                               ([request BKR_isEquivalentToRequestFrame:scene.currentRequest options:options])
                               );
        if (
            matchesRequest &&
            !item.expectsRedirect
            ) {
            responseStub = scene.finalResponseStub;
            // stop looping when we have a match
            break;
        } else if (item.expectsRedirect) {
            // else match redirects if we still expect some
            BKRRedirectFrame *redirectFrame = [scene redirectFrameForRedirect:item.numberOfRedirectsStubbed];
            // need to build a proper URL from a redirect, example:
            // [[NSURL URLWithString:@"/" relativeToURL:request.URL] absoluteURL]
            if ([request BKR_isEquivalentToRequestFrame:redirectFrame.requestFrame options:options]) {
                responseStub = [scene responseStubForRedirectFrame:redirectFrame];
                // stop looping when we have a match
                break;
            }
        }
    }
    return responseStub;
}

#pragma mark - Optional

- (NSTimeInterval)requestTimeForRequest:(NSURLRequest *)request withStub:(BKRResponseStub *)responseStub {
    return 0;
}

- (NSTimeInterval)responseTimeForRequest:(NSURLRequest *)request withStub:(BKRResponseStub *)responseStub {
    return 0;
}

- (NSDictionary *)requestComparisonOptions {
    return @{
             kBKRShouldIgnoreQueryItemsOrderOptionsKey: @YES,
             };
}

@end
