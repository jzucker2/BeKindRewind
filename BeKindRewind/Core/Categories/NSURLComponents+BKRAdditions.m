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

+ (NSArray<NSString *> *)BKR_ignoringURLComponentsProperties:(NSDictionary *)options {
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

+ (NSArray<NSString *> *)BKR_overridingComparingURLComponentsProperties:(NSDictionary *)options {
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

+ (BOOL)BKR_shouldIgnoreURLComponentsQueryItems:(NSDictionary *)options {
    NSArray<NSString *> *ignoringNSURLComponents = [self BKR_ignoringURLComponentsProperties:options];
    return [ignoringNSURLComponents containsObject:@"queryItems"];
}

+ (NSArray<NSString *> *)BKR_comparingURLComponentsProperties:(NSDictionary *)options {
    NSMutableArray<NSString *> *comparingComponents = [self BKR_URLComponentsProperties].mutableCopy;
    
    NSArray<NSString *> *ignoringNSURLComponents = [self BKR_ignoringURLComponentsProperties:options];
    NSArray<NSString *> *overridingNSURLComponents = [self BKR_overridingComparingURLComponentsProperties:options];
    
    [comparingComponents removeObjectsInArray:ignoringNSURLComponents];
    [comparingComponents removeObjectsInArray:overridingNSURLComponents];
    
    return comparingComponents.copy;
}

+ (BOOL)BKR_shouldCompareURLComponentsQueryItems:(NSDictionary *)options {
    BOOL shouldIgnoreQueryComponents = [self BKR_shouldIgnoreURLComponentsQueryItems:options];
    if (shouldIgnoreQueryComponents) {
        return NO;
    }
    // if we aren't ignoring it, make sure we aren't overriding it
    NSArray<NSString *> *overridingNSURLComponents = [self BKR_overridingComparingURLComponentsProperties:options];
    return ![overridingNSURLComponents containsObject:@"queryItems"]; // if we are overriding, then we shouldn't compare it
}

@end
