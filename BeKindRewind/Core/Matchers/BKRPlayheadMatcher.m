//
//  BKRPlayheadMatcher.m
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import "BKRPlayheadMatcher.h"
#import "NSURLComponents+BKRAdditions.h"

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
//        // try to return early if we already have a mismatch
//        if (!matchesRequest) {
//            continue;
//        }
        BOOL shouldOverrideMatching = [NSURLComponents BKR_shouldOverrideComparingURLComponentsProperties:options];
        
        if (shouldOverrideMatching) {
            if (![self respondsToSelector:@selector(hasMatchForURLComponent:withRequestComponentValue:possibleMatchComponentValue:)]) {
                NSLog(@"You must implement `hasMatchForURLComponent:withRequestComponentValue:possibleMatchComponentValue:` from the `BKRRequestMatching` protocol for override execution.");
            } else {
                NSArray<NSString *> *overridingComponents = [NSURLComponents BKR_overridingComparingURLComponentsProperties:options];
                BOOL hasOverrideMatch = [request BKR_isEquivalentForURLComponents:overridingComponents toOtherRequestURLString:scene.currentRequest.URLAbsoluteString withComparisonBlock:^BOOL(NSString *componentKey, id requestComponentValue, id otherRequestComponentValue) {
                    return [self hasMatchForURLComponent:componentKey withRequestComponentValue:requestComponentValue possibleMatchComponentValue:otherRequestComponentValue];
                }];
                if (!hasOverrideMatch) {
                    continue;
                }
            }
        }
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
            BOOL hasRedirectMatch = [request BKR_isEquivalentToResponseFrame:redirectFrame.responseFrame options:options];
            if (!hasRedirectMatch) {
                continue;
            }
            BOOL shouldOverrideMatching = [NSURLComponents BKR_shouldOverrideComparingURLComponentsProperties:options];
            
            if (shouldOverrideMatching) {
                if (![self respondsToSelector:@selector(hasMatchForURLComponent:withRequestComponentValue:possibleMatchComponentValue:)]) {
                    NSLog(@"You must implement `hasMatchForURLComponent:withRequestComponentValue:possibleMatchComponentValue:` from the `BKRRequestMatching` protocol for override execution.");
                } else {
                    NSArray<NSString *> *overridingComponents = [NSURLComponents BKR_overridingComparingURLComponentsProperties:options];
                    BOOL hasOverrideMatch = [request BKR_isEquivalentForURLComponents:overridingComponents toOtherRequestURLString:scene.currentRequest.URLAbsoluteString withComparisonBlock:^BOOL(NSString *componentKey, id requestComponentValue, id otherRequestComponentValue) {
                        return [self hasMatchForURLComponent:componentKey withRequestComponentValue:requestComponentValue possibleMatchComponentValue:otherRequestComponentValue];
                    }];
                    if (!hasOverrideMatch) {
                        continue;
                    }
                }
            }
            responseStub = [scene responseStubForRedirectFrame:redirectFrame];
            // stop looping when we have a match
            break;
        }
    }
    return responseStub;
}

#pragma mark - Optional

- (NSDictionary *)requestComparisonOptions {
    return @{
             kBKRShouldIgnoreQueryItemsOrderOptionsKey: @YES,
             };
}

@end
