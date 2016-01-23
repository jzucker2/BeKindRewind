//
//  BKRPlayheadMatcher.m
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import "BKRPlayheadMatcher.h"

@implementation BKRPlayheadMatcher

+ (id<BKRRequestMatching>)matcher {
    return [[self alloc] init];
}

- (BOOL)hasMatchForRequest:(NSURLRequest *)request withPlayheadIdentifier:(NSString *)playheadIdentifier inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes {
    return YES;
}

- (BKRPlayableScene *)matchForRequest:(NSURLRequest *)request withPlayheadIdentifier:(NSString *)playheadIdentifier inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes {
    return nil;
}

@end
