//
//  NSURLRequest+BKRAdditions.m
//  Pods
//
//  Created by Jordan Zucker on 3/14/16.
//
//

#import "NSURLRequest+BKRAdditions.h"
#import "BKRRequestFrame.h"
#import "BKRConstants.h"

NSString *kBKRShouldIgnoreQueryItemsOrderOptionsKey = @"BKRShouldIgnoreQueryItemsOrderOptionsKey";
NSString *kBKRIgnoreQueryItemNamesOptionsKey = @"BKRIgnoreQueryItemNamesOptionsKey";
NSString *kBKRIgnoreNSURLComponentsPropertiesOptionsKey = @"BKRIgnoreNSURLComponentsPropertiesOptionsKey";
NSString *kBKRCompareHTTPBodyOptionsKey = @"BKRCompareHTTPBodyKeyOptionsKey";

@implementation NSURLRequest (BKRAdditions)

- (BOOL)BKR_isEquivalentToRequest:(NSURLRequest *)otherRequest options:(NSDictionary *)options {
    return [self BKR_isEquivalentToRequestURLString:otherRequest.URL.absoluteString options:options];
}

- (BOOL)BKR_isEquivalentToRequestURLString:(NSString *)otherRequestURLString options:(NSDictionary *)options {
    if (!otherRequestURLString) {
        return NO;
    }

    NSArray<NSString *> *componentProperties = [self _URLComponentProperties];
    NSURLComponents *requestComponents = [NSURLComponents componentsWithString:self.URL.absoluteString];
    NSURLComponents *otherRequestComponents = [NSURLComponents componentsWithString:otherRequestURLString];
    
    BOOL ignoreQueryItemsOrder = NO;
    NSArray<NSString *> *ignoreNSURLComponentsProperties = nil;
    NSArray<NSString *> *ignoreQueryItemNames = nil;
    if (options) {
        if (options[kBKRIgnoreNSURLComponentsPropertiesOptionsKey]) {
            NSAssert([options[kBKRIgnoreNSURLComponentsPropertiesOptionsKey] isKindOfClass:[NSArray class]], @"Value for kBKRIgnoreNSURLComponentsProperties is expected to be an NSArray of NSString property names");
            ignoreNSURLComponentsProperties = options[kBKRIgnoreNSURLComponentsPropertiesOptionsKey];
        }
        if (
            options[kBKRShouldIgnoreQueryItemsOrderOptionsKey] &&
            (![ignoreNSURLComponentsProperties containsObject:@"queryItems"])
            ) {
            NSAssert([options[kBKRShouldIgnoreQueryItemsOrderOptionsKey] isKindOfClass:[NSNumber class]], @"Value for kBKRShouldIgnoreQueryItemsOrder is expected to be a BOOL wrapped in an NSNumber");
            ignoreQueryItemsOrder = [options[kBKRShouldIgnoreQueryItemsOrderOptionsKey] boolValue];
        }
        if (
            options[kBKRIgnoreQueryItemNamesOptionsKey] &&
            (![ignoreNSURLComponentsProperties containsObject:@"queryItems"])
            ) {
            NSAssert([options[kBKRIgnoreQueryItemNamesOptionsKey] isKindOfClass:[NSArray class]], @"Value for kBKRIgnoreQueryItemNames is expected to be an NSArray of NSString query item names");
            ignoreQueryItemNames = options[kBKRIgnoreQueryItemNamesOptionsKey];
        }
    }
    
    NSMutableArray *comparingComponents = componentProperties.mutableCopy;
    [comparingComponents removeObjectsInArray:ignoreNSURLComponentsProperties]; // remove ignoring components
    for (NSString *componentKey in comparingComponents.copy) {
        if ([componentKey isEqualToString:@"queryItems"]) {
            // handle query items separately
            NSArray<NSURLQueryItem *> *finalRequestQueryItems = nil;
            NSArray<NSURLQueryItem *> *finalOtherRequestQueryItems = nil;
            NSMutableArray<NSURLQueryItem *> *temporaryRequestQueryItems = requestComponents.queryItems.mutableCopy;
            NSMutableArray<NSURLQueryItem *> *temporaryOtherRequestQueryItems = otherRequestComponents.queryItems.mutableCopy;
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
                // neither object has query items, continue comparing other components
                continue;
            }
            if (
                (!finalRequestQueryItems && finalOtherRequestQueryItems) ||
                (finalRequestQueryItems && !finalOtherRequestQueryItems)
                ) {
                // if there are no query items for one of the two objects we are comparing, then they cannot be equal
                return NO;
            }
            if (ignoreQueryItemsOrder) {
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
            if (![self _requestComponentString:[requestComponents valueForKey:componentKey] matchesOtherRequestComponentString:[otherRequestComponents valueForKey:componentKey]]) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL)_requestComponentString:(NSString *)requestComponentString matchesOtherRequestComponentString:(NSString *)otherRequestComponentString {
    // if they both exist
    if (
        requestComponentString &&
        otherRequestComponentString
        ) {
        // return whether the strings exist if there are 2 things to compare
        return [requestComponentString isEqualToString:otherRequestComponentString];
    } else if (
               (requestComponentString && !otherRequestComponentString) ||
               (!requestComponentString && otherRequestComponentString)
               ) {
        // if one exists but not the other, then return NO, they can't possibly match
        return NO;
    }
    // if both don't exist, then return YES
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

- (NSArray *)_URLComponentProperties {
    static NSArray<NSString *> *componentProperties = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        componentProperties = @[@"scheme", @"user", @"password", @"host", @"port", @"path", @"queryItems", @"fragment"];
    });
    return componentProperties;
}

@end
