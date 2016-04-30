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

@end
