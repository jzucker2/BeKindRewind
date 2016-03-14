//
//  NSURLRequest+BKRAdditions.m
//  Pods
//
//  Created by Jordan Zucker on 3/14/16.
//
//

#import "NSURLRequest+BKRAdditions.h"
#import "BKRConstants.h"

@implementation NSURLRequest (BKRAdditions)

- (BOOL)BKR_isEquivalentToRequest:(NSURLRequest *)otherRequest {
//    NSString *redirectLocation = nil;
//    if (self.allHTTPHeaderFields[@"Location"]) {
//        redirectLocation = self.allHTTPHeaderFields[@"Location"];
//    }
//    return (redirectLocation ? YES : NO);
    NSURLComponents *requestComponents = [NSURLComponents componentsWithString:self.URL.absoluteString];
    NSURLComponents *otherComponents = [NSURLComponents componentsWithString:otherRequest.URL.absoluteString];
    if (![requestComponents.scheme isEqualToString:otherComponents.scheme]) {
        return NO;
    }
    if (![requestComponents.user isEqualToString:otherComponents.user]) {
        return NO;
    }
}

- (BOOL)_compareComponentsForOtherRequest:(NSURLRequest *)otherRequest {
    return NO;
}

@end
