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
        // this could be a network event that is in the process of finishing
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
        
        // then handle overrides
        BOOL shouldOverrideMatching = [NSURLComponents BKR_shouldOverrideComparingURLComponentsProperties:options];
        if (shouldOverrideMatching) {
            BOOL hasOverrideMatch = [self _overrideForRequest:request matchesRequestURLString:scene.currentRequest.URLAbsoluteString withOptions:options];
            if (!hasOverrideMatch) {
                continue;
            }
        }
        if (
            matchesRequest &&
            !item.expectsRedirect
            ) {
            responseStub = scene.finalResponseStub;
            break; // stop looping when we have a match
        } else if (item.expectsRedirect) {
            // else match redirects if we still expect something
            // extract the specific redirect
            BKRRedirectFrame *redirectFrame = [scene redirectFrameForRedirect:item.numberOfRedirectsStubbed];
            // extract the response URL string for comparing the redirect
            NSString *redirectResponseURLString = redirectFrame.responseFrame.URLAbsoluteString;
            
            BOOL shouldOverrideMatching = [NSURLComponents BKR_shouldOverrideComparingURLComponentsProperties:options];
            if (shouldOverrideMatching) {
                BOOL hasOverrideMatch = [self _overrideForRequest:request matchesRequestURLString:redirectResponseURLString withOptions:options];
                if (!hasOverrideMatch) {
                    continue;
                }
            }
            if ([request BKR_isEquivalentToRequestURLString:redirectResponseURLString options:options]) {
                responseStub = [scene responseStubForRedirectFrame:redirectFrame];
                break; // stop looping when we have a match
            }

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

#pragma mark - Custom

- (BOOL)_overrideForRequest:(NSURLRequest *)request matchesRequestURLString:(NSString *)requestURLString withOptions:(NSDictionary *)options {
    if (
        (![self respondsToSelector:@selector(hasMatchForURLComponent:withRequestComponentValue:possibleMatchComponentValue:)]) &&
        (![self respondsToSelector:@selector(hasOverrideMatchForURLComponent:withRequestComponentValue:possibleMatchComponentValue:)])
        ) {
        NSLog(@"You must implement `hasOverrideMatchForURLComponent:withRequestComponentValue:possibleMatchComponentValue:` from the `BKRRequestMatching` protocol for override matching.");
    } else {
        NSArray<NSString *> *overridingComponents = [NSURLComponents BKR_overridingComparingURLComponentsProperties:options];
        return [request BKR_isEquivalentForURLComponents:overridingComponents toOtherRequestURLString:requestURLString withComparisonBlock:^BOOL(NSString *componentKey, id requestComponentValue, id otherRequestComponentValue) {
            if ([self respondsToSelector:@selector(hasOverrideMatchForURLComponent:withRequestComponentValue:possibleMatchComponentValue:)]) {
                return [self hasOverrideMatchForURLComponent:componentKey withRequestComponentValue:requestComponentValue possibleMatchComponentValue:otherRequestComponentValue];
            } else {
                return [self hasMatchForURLComponent:componentKey withRequestComponentValue:requestComponentValue possibleMatchComponentValue:otherRequestComponentValue];
            }
        }];
    }
    return YES;
}

@end
