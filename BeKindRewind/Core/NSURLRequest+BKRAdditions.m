//
//  NSURLRequest+BKRAdditions.m
//  Pods
//
//  Created by Jordan Zucker on 3/14/16.
//
//

#import "NSURLRequest+BKRAdditions.h"
#import "BKRConstants.h"

NSString *kBKRShouldIgnoreQueryItemsOrder = @"BKRShouldIgnoreQueryItemsOrder";
NSString *kBKRIgnoreQueryItemNames = @"BKRIgnoreQueryItemNames";
NSString *kBKRIgnoreNSURLComponentsProperties = @"BKRIgnoreNSURLComponentsProperties";

@implementation NSURLRequest (BKRAdditions)

- (BOOL)BKR_isEquivalentToRequest:(NSURLRequest *)otherRequest options:(NSDictionary *)options {
//    @property (nullable, copy) NSString *scheme; // Attempting to set the scheme with an invalid scheme string will cause an exception.
//    @property (nullable, copy) NSString *user;
//    @property (nullable, copy) NSString *password;
//    @property (nullable, copy) NSString *host;
//    @property (nullable, copy) NSNumber *port; // Attempting to set a negative port number will cause an exception.
//    @property (nullable, copy) NSString *path;
//    @property (nullable, copy) NSString *query;
//    @property (nullable, copy) NSString *fragment;
    __block NSArray<NSString *> *componentProperties = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        componentProperties = @[@"scheme", @"user", @"password", @"host", @"port", @"path", @"queryItems", @"fragment"];
    });
    NSURLComponents *requestComponents = [NSURLComponents componentsWithString:self.URL.absoluteString];
    NSURLComponents *otherRequestComponents = [NSURLComponents componentsWithString:otherRequest.URL.absoluteString];
    
    BOOL ignoreQueryItemsOrder = NO;
    NSArray<NSString *> *ignoreNSURLComponentsProperties = nil;
    NSArray<NSString *> *ignoreQueryItemNames = nil;
    if (options) {
        if (options[kBKRIgnoreNSURLComponentsProperties]) {
            NSAssert([options[kBKRIgnoreNSURLComponentsProperties] isKindOfClass:[NSArray class]], @"Value for kBKRIgnoreNSURLComponentsProperties is expected to be an NSArray of NSString property names");
            ignoreNSURLComponentsProperties = options[kBKRIgnoreNSURLComponentsProperties];
        }
        if (
            options[kBKRShouldIgnoreQueryItemsOrder] &&
            (![ignoreNSURLComponentsProperties containsObject:@"queryItems"])
            ) {
            NSAssert([options[kBKRShouldIgnoreQueryItemsOrder] isKindOfClass:[NSNumber class]], @"Value for kBKRShouldIgnoreQueryItemsOrder is expected to be a BOOL wrapped in an NSNumber");
            ignoreQueryItemsOrder = [options[kBKRShouldIgnoreQueryItemsOrder] boolValue];
        }
        if (
            options[kBKRIgnoreQueryItemNames] &&
            (![ignoreNSURLComponentsProperties containsObject:@"queryItems"])
            ) {
            NSAssert([options[kBKRIgnoreQueryItemNames] isKindOfClass:[NSArray class]], @"Value for kBKRIgnoreQueryItemNames is expected to be an NSArray of NSString query item names");
            ignoreQueryItemNames = options[kBKRIgnoreQueryItemNames];
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
                NSPredicate *removeIgnoringQueryItemNamesPredicate = [NSPredicate predicateWithFormat:@"name IN %@", ignoreQueryItemNames];
                finalRequestQueryItems = [temporaryRequestQueryItems filteredArrayUsingPredicate:removeIgnoringQueryItemNamesPredicate];
                finalOtherRequestQueryItems = [temporaryOtherRequestQueryItems filteredArrayUsingPredicate:removeIgnoringQueryItemNamesPredicate];
            }
            if (!finalOtherRequestQueryItems && !finalOtherRequestQueryItems) {
                return YES;
            }
            if (
                (!finalRequestQueryItems && finalOtherRequestQueryItems) ||
                (finalRequestQueryItems && !finalOtherRequestQueryItems)
                ) {
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

@end
