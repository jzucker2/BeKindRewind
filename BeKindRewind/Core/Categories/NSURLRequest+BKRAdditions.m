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

NSString *kBKRShouldIgnoreQueryItemsOrderOptionsKey = @"BKRShouldIgnoreQueryItemsOrderOptionsKey"; // @YES by default
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
            return [NSURLComponents BKR_componentQueryItems:requestComponentValue matchesOtherComponentQueryItems:otherRequestComponentValue withOptions:options];
        } else {
            return [NSURLComponents BKR_componentString:requestComponentValue matchesOtherComponentString:otherRequestComponentValue];
        }
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
