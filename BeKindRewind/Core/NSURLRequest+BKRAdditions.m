//
//  NSURLRequest+BKRAdditions.m
//  Pods
//
//  Created by Jordan Zucker on 3/14/16.
//
//

#import "NSURLRequest+BKRAdditions.h"

@implementation NSURLRequest (BKRAdditions)

- (BOOL)isRedirect {
    NSString *redirectLocation = nil;
    if (self.allHTTPHeaderFields[@"Location"]) {
        redirectLocation = self.allHTTPHeaderFields[@"Location"];
    }
    return (redirectLocation ? YES : NO);
}

@end
