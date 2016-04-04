//
//  NSURL+BKRAdditions.m
//  Pods
//
//  Created by Jordan Zucker on 3/17/16.
//
//

#import "NSURL+BKRAdditions.h"

@implementation NSURL (BKRAdditions)

- (nullable instancetype)BKR_baseURL {
    return [[self class] BKR_baseURLFromAbsoluteURL:self];
}

+ (nullable instancetype)BKR_baseURLFromAbsoluteURL:(NSURL *)absoluteURL {
    return [[NSURL URLWithString:@"/" relativeToURL:absoluteURL] absoluteURL];
}

@end
