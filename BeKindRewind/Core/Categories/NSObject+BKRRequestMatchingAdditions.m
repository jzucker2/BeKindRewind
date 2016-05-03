//
//  NSObject+BKRRequestMatchingAdditions.m
//  Pods
//
//  Created by Jordan Zucker on 5/3/16.
//
//

#import <objc/message.h>
#import "NSObject+BKRRequestMatchingAdditions.h"
#import "NSURLComponents+BKRAdditions.h"
#import "NSURLRequest+BKRAdditions.h"
#import "BKRScene+Playable.h"

@implementation NSObject (BKRRequestMatchingAdditions)

- (BOOL)BKR_overrideForRequest:(NSURLRequest *)request matchesRequestURLString:(NSString *)requestURLString withOptions:(NSDictionary *)options {
    if (
        (![self respondsToSelector:@selector(hasMatchForURLComponent:withRequestComponentValue:possibleMatchComponentValue:)]) &&
        (![self respondsToSelector:@selector(hasOverrideMatchForURLComponent:withRequestComponentValue:possibleMatchComponentValue:)])
        ) {
        NSLog(@"You must implement `hasOverrideMatchForURLComponent:withRequestComponentValue:possibleMatchComponentValue:` or the deprecated `hasMatchForURLComponent:withRequestComponentValue:possibleMatchComponentValue:` from the `BKRRequestMatching` protocol for override execution.");
    } else {
        NSArray<NSString *> *overridingComponents = [NSURLComponents BKR_overridingComparingURLComponentsProperties:options];
        return [request BKR_isEquivalentForURLComponents:overridingComponents toOtherRequestURLString:requestURLString withComparisonBlock:^BOOL(NSString *componentKey, id requestComponentValue, id otherRequestComponentValue) {
            if ([self respondsToSelector:@selector(hasOverrideMatchForURLComponent:withRequestComponentValue:possibleMatchComponentValue:)]) {
//                return [self hasOverrideMatchForURLComponent:componentKey withRequestComponentValue:requestComponentValue possibleMatchComponentValue:otherRequestComponentValue];
                return [self _executeOverrideMatchSelector:@selector(hasOverrideMatchForURLComponent:withRequestComponentValue:possibleMatchComponentValue:) withURLComponent:componentKey withRequestComponentValue:requestComponentValue possibleMatchComponentValue:otherRequestComponentValue];
            } else {
//                return [self hasMatchForURLComponent:componentKey withRequestComponentValue:requestComponentValue possibleMatchComponentValue:otherRequestComponentValue];
                return [self _executeOverrideMatchSelector:@selector(hasMatchForURLComponent:withRequestComponentValue:possibleMatchComponentValue:) withURLComponent:componentKey withRequestComponentValue:requestComponentValue possibleMatchComponentValue:otherRequestComponentValue];
            }
        }];
    }
    return YES;
}

- (BOOL)_executeOverrideMatchSelector:(SEL)overrideMatchSelector withURLComponent:(NSString *)componentKey withRequestComponentValue:(id)requestComponentValue possibleMatchComponentValue:(id)possibleMatchComponentValue {
    return [self performSelector:overrideMatchSelector withObject:componentKey withObject:requestComponentValue];
}

@end
