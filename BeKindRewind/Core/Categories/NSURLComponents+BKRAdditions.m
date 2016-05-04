//
//  NSURLComponents+BKRAdditions.m
//  Pods
//
//  Created by Jordan Zucker on 4/27/16.
//
//

#import "NSURLComponents+BKRAdditions.h"
#import "NSURLRequest+BKRAdditions.h"

@implementation NSURLComponents (BKRAdditions)

+ (NSArray<NSString *> *)BKR_URLComponentsProperties {
    static NSArray<NSString *> *componentProperties = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        componentProperties = @[@"scheme", @"user", @"password", @"host", @"port", @"path", @"queryItems", @"fragment"];
    });
    return componentProperties;
}

+ (NSArray<NSString *> *)BKR_rawIgnoringURLComponentsProperties:(NSDictionary *)options {
    NSArray<NSString *> *ignoringNSURLComponentsProperties = @[];
    if (options) {
        // remove ignoring components
        if (options[kBKRIgnoreNSURLComponentsPropertiesOptionsKey]) {
            NSAssert([options[kBKRIgnoreNSURLComponentsPropertiesOptionsKey] isKindOfClass:[NSArray class]], @"Value for kBKRIgnoreNSURLComponentsProperties is expected to be an NSArray of NSString property names");
            ignoringNSURLComponentsProperties = options[kBKRIgnoreNSURLComponentsPropertiesOptionsKey];
        }
    }
    return ignoringNSURLComponentsProperties;
    
}

+ (NSArray<NSString *> *)BKR_rawOverridingComparingURLComponentsProperties:(NSDictionary *)options {
    NSArray<NSString *> *overridingNSURLComponentsProperties = @[];
    if (options) {
        // remove ignoring components
        if (options[kBKROverrideNSURLComponentsPropertiesOptionsKey]) {
            NSAssert([options[kBKROverrideNSURLComponentsPropertiesOptionsKey] isKindOfClass:[NSArray class]], @"Value for kBKROverrideNSURLComponentsPropertiesOptionsKey is expected to be an NSArray of NSString property names");
            overridingNSURLComponentsProperties = options[kBKROverrideNSURLComponentsPropertiesOptionsKey];
        }
    }
    return overridingNSURLComponentsProperties;
}

+ (NSArray<NSString *> *)BKR_overridingComparingURLComponentsProperties:(NSDictionary *)options {
    NSMutableArray<NSString *> *overridingComparingComponents = [[self BKR_rawOverridingComparingURLComponentsProperties:options] mutableCopy];
    
    NSArray<NSString *> *ignoringComponents = [self BKR_rawIgnoringURLComponentsProperties:options];
    [overridingComparingComponents removeObjectsInArray:ignoringComponents];
    
    return overridingComparingComponents.copy;
}

+ (NSArray<NSString *> *)BKR_defaultComparingURLComponentsProperties:(NSDictionary *)options {
    NSMutableArray<NSString *> *defaultComparingComponents = [[self BKR_URLComponentsProperties] mutableCopy];
    
    NSArray<NSString *> *ignoringComponents = [self BKR_rawIgnoringURLComponentsProperties:options];
    NSArray<NSString *> *overridingComponents = [self BKR_rawOverridingComparingURLComponentsProperties:options];
    
    [defaultComparingComponents removeObjectsInArray:ignoringComponents];
    [defaultComparingComponents removeObjectsInArray:overridingComponents];
    
    return defaultComparingComponents.copy;
}

+ (BOOL)BKR_shouldCompareURLComponentsProperties:(NSDictionary *)options {
    NSMutableArray<NSString *> *defaultComparingComponents = [[self BKR_URLComponentsProperties] mutableCopy];
    
    NSArray<NSString *> *ignoringComponents = [self BKR_rawIgnoringURLComponentsProperties:options];
    [defaultComparingComponents removeObjectsInArray:ignoringComponents];
    
    return (defaultComparingComponents.count ? YES : NO);
}

+ (BOOL)BKR_shouldOverrideComparingURLComponentsProperties:(NSDictionary *)options {
    NSArray<NSString *> *overridingComponents = [self BKR_overridingComparingURLComponentsProperties:options];
    return (overridingComponents.count ? YES : NO);
}

+ (BOOL)BKR_componentString:(NSString *)componentString matchesOtherComponentString:(NSString *)otherComponentString {
    // if they both exist
    if (
        componentString &&
        otherComponentString
        ) {
        // return whether the strings exist if there are 2 things to compare
        return [componentString isEqualToString:otherComponentString];
    } else if (
               (componentString && !otherComponentString) ||
               (!componentString && otherComponentString)
               ) {
        // if one exists but not the other, then return NO, they can't possibly match
        return NO;
    }
    // if both don't exist, then return YES
    return YES;
}

+ (BOOL)BKR_componentQueryItems:(NSArray<NSURLQueryItem *> *)componentQueryItems matchesOtherComponentQueryItems:(NSArray<NSURLQueryItem *> *)otherComponentQueryItems withOptions:(NSDictionary *)options {
    // first check if both are nil, if so, then return YES
    if (
        !componentQueryItems &&
        !otherComponentQueryItems
        ) {
        return YES;
    }
    BOOL shouldIgnoreQueryItemsOrder = YES; // this is YES by default (see docs kBKRShouldIgnoreQueryItemsOrderOptionsKey)
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
    
    // we create an empty mutable array and add the comparing query items to it in case
    // one of these is nil, then we avoid throwing an exception and can compare empty
    // arrays instead of a possibly nil object
    NSMutableArray<NSURLQueryItem *> *temporaryRequestQueryItems = [NSMutableArray array];
    NSMutableArray<NSURLQueryItem *> *temporaryOtherRequestQueryItems = [NSMutableArray array];
    [temporaryRequestQueryItems addObjectsFromArray:componentQueryItems];
    [temporaryOtherRequestQueryItems addObjectsFromArray:otherComponentQueryItems];
    
    // now we try to remove ignoring query items
    if (ignoreQueryItemNames.count) {
        NSPredicate *removeIgnoringQueryItemNamesPredicate = [NSPredicate predicateWithFormat:@"NOT (name IN %@)", ignoreQueryItemNames];
        finalRequestQueryItems = [temporaryRequestQueryItems filteredArrayUsingPredicate:removeIgnoringQueryItemNamesPredicate];
        finalOtherRequestQueryItems = [temporaryOtherRequestQueryItems filteredArrayUsingPredicate:removeIgnoringQueryItemNamesPredicate];
    } else {
        // if we are not ignoring a specific query item, then assign all query items for comparison
        finalRequestQueryItems = temporaryRequestQueryItems.copy;
        finalOtherRequestQueryItems = temporaryOtherRequestQueryItems.copy;
    }
    // we can assume both arrays exist because of how we built them above
    if (!finalOtherRequestQueryItems.count && !finalOtherRequestQueryItems.count) {
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
        return [requestQueryItems isEqualToSet:otherRequestQueryItems];
    } else {
        return [finalRequestQueryItems isEqualToArray:finalOtherRequestQueryItems];
    }
}

@end
