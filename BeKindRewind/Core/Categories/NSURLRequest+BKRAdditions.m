//
//  NSURLRequest+BKRAdditions.m
//  Pods
//
//  Created by Jordan Zucker on 3/14/16.
//
//

#import "NSURLRequest+BKRAdditions.h"
#import "NSURLComponents+BKRAdditions.h"
#import "BKRRequestFrame.h"
#import "BKRResponseFrame.h"
#import "BKRConstants.h"

NSString *kBKRShouldIgnoreQueryItemsOrderOptionsKey = @"BKRShouldIgnoreQueryItemsOrderOptionsKey";
NSString *kBKRIgnoreQueryItemNamesOptionsKey = @"BKRIgnoreQueryItemNamesOptionsKey";
NSString *kBKRIgnoreNSURLComponentsPropertiesOptionsKey = @"BKRIgnoreNSURLComponentsPropertiesOptionsKey";
NSString *kBKRCompareHTTPBodyOptionsKey = @"BKRCompareHTTPBodyKeyOptionsKey";
NSString *kBKROverrideNSURLComponentsPropertiesOptionsKey = @"BKROverrideNSURLComponentsPropertiesOptionsKey";

@implementation NSURLRequest (BKRAdditions)

- (BOOL)BKR_isEquivalentToRequest:(NSURLRequest *)otherRequest options:(NSDictionary *)options {
    return [self BKR_isEquivalentToRequestURLString:otherRequest.URL.absoluteString options:options];
}

- (BOOL)BKR_isEquivalentToResponseFrame:(BKRResponseFrame *)responseFrame options:(NSDictionary *)options {
    return [self BKR_isEquivalentToRequestURLString:responseFrame.URLAbsoluteString options:options];
}

- (BOOL)BKR_isEquivalentToRequestURLString:(NSString *)otherRequestURLString options:(NSDictionary *)options {
    // This the comparing object doesn't have a valid request URL String than let's return NO immediately
    if (!otherRequestURLString) {
        return NO;
    }
    
    // Next let's check the options dictionary to see if there's even anything to compare
    if (![NSURLComponents BKR_shouldCompareURLComponentsProperties:options]) {
        return YES;
    }
    
    // We are only dealing with default comparisons here
    NSArray<NSString *> *comparingComponents = [NSURLComponents BKR_defaultComparingURLComponentsProperties:options];
    BOOL hasMatch = [self BKR_isEquivalentForURLComponents:comparingComponents toOtherRequestURLString:otherRequestURLString withComparisonBlock:^BOOL(NSString *componentName, id requestComponentValue, id otherRequestComponentValue) {
        // handle query items separately
        if ([componentName isEqualToString:@"queryItems"]) {
            BOOL shouldIgnoreQueryItemsOrder = YES;
            NSArray<NSString *> *ignoreQueryItemNames = @[];
            if (options) {
                if (options[kBKRShouldIgnoreQueryItemsOrderOptionsKey]) {
                    NSAssert([options[kBKRShouldIgnoreQueryItemsOrderOptionsKey] isKindOfClass:[NSNumber class]], @"Value for kBKRShouldIgnoreQueryItemsOrder is expected to be a BOOL wrapped in an NSNumber");
                    shouldIgnoreQueryItemsOrder = [options[kBKRShouldIgnoreQueryItemsOrderOptionsKey] boolValue];
                }
                if (options[kBKRIgnoreQueryItemNamesOptionsKey]) {
                    NSAssert([options[kBKRIgnoreQueryItemNamesOptionsKey] isKindOfClass:[NSArray class]], @"Value for kBKRIgnoreQueryItemNames is expected to be an NSArray of NSString query item names");
                    ignoreQueryItemNames = options[kBKRIgnoreQueryItemNamesOptionsKey];
                }
            }
            
            NSArray<NSURLQueryItem *> *finalRequestQueryItems = nil;
            NSArray<NSURLQueryItem *> *finalOtherRequestQueryItems = nil;
            NSMutableArray<NSURLQueryItem *> *temporaryRequestQueryItems = [requestComponentValue mutableCopy];
            NSMutableArray<NSURLQueryItem *> *temporaryOtherRequestQueryItems = [otherRequestComponentValue mutableCopy];
            if (ignoreQueryItemNames.count) {
                NSPredicate *removeIgnoringQueryItemNamesPredicate = [NSPredicate predicateWithFormat:@"NOT (name IN %@)", ignoreQueryItemNames];
                finalRequestQueryItems = [temporaryRequestQueryItems filteredArrayUsingPredicate:removeIgnoringQueryItemNamesPredicate];
                finalOtherRequestQueryItems = [temporaryOtherRequestQueryItems filteredArrayUsingPredicate:removeIgnoringQueryItemNamesPredicate];
            } else {
                // if we are not ignoring a specific query item, then assign all query items for comparison
                finalRequestQueryItems = temporaryRequestQueryItems.copy;
                finalOtherRequestQueryItems = temporaryOtherRequestQueryItems.copy;
            }
            if (!finalOtherRequestQueryItems && !finalOtherRequestQueryItems) {
                // neither object has query items, return YES to continue comparing other components
                return YES;
            }
            if (
                (!finalRequestQueryItems && finalOtherRequestQueryItems) ||
                (finalRequestQueryItems && !finalOtherRequestQueryItems)
                ) {
                // if there are no query items for one of the two objects we are comparing, then they cannot be equal
                return NO;
            }
            if (shouldIgnoreQueryItemsOrder) {
                NSCountedSet *requestQueryItems = [NSCountedSet setWithArray:finalRequestQueryItems];
                NSCountedSet *otherRequestQueryItems = [NSCountedSet setWithArray:finalOtherRequestQueryItems];
                if (![requestQueryItems isEqualToSet:otherRequestQueryItems]) {
                    return NO;
                }
            } else {
                if (![finalRequestQueryItems isEqualToArray:finalOtherRequestQueryItems]) {
                    return NO;
                }
            }
        } else {
            if (![NSURLComponents BKR_componentString:requestComponentValue matchesOtherComponentString:otherRequestComponentValue]) {
                return NO;
            }
        }
        return YES;
    }];
    
    return hasMatch;
}

- (BOOL)BKR_isEquivalentForURLComponents:(NSArray<NSString *> *)URLComponents toOtherRequestURLString:(NSString *)otherRequestURLString withComparisonBlock:(BKRURLComponentComparisonBlock)componentComparisonBlock {
    NSParameterAssert(URLComponents);
    NSParameterAssert(componentComparisonBlock);
    NSURLComponents *requestURLComponents = [NSURLComponents componentsWithString:self.URL.absoluteString];
    NSURLComponents *otherRequestURLComponents = [NSURLComponents componentsWithString:otherRequestURLString];
    for (NSString *componentKey in URLComponents) {
        NSString *requestComponentStringValue = [requestURLComponents valueForKey:componentKey];
        NSString *otherRequestComponentStringValue = [otherRequestURLComponents valueForKey:componentKey];
        if (!componentComparisonBlock(componentKey, requestComponentStringValue, otherRequestComponentStringValue)) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)BKR_isEquivalentToRequestFrame:(BKRRequestFrame *)requestFrame options:(NSDictionary *)options {
    BOOL shouldCompareHTTPBody = NO;
    if (options) {
        if (options[kBKRCompareHTTPBodyOptionsKey]) {
            shouldCompareHTTPBody = [options[kBKRCompareHTTPBodyOptionsKey] boolValue];
        }
    }
    if (shouldCompareHTTPBody) {
        if (![self.HTTPBody isEqualToData:requestFrame.HTTPBody]) {
            return NO;
        }
    }
    return [self BKR_isEquivalentToRequestURLString:requestFrame.URLAbsoluteString options:options];
}

@end
