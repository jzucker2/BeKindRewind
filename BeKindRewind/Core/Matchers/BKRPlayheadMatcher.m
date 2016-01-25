//
//  BKRPlayheadMatcher.m
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import "BKRPlayheadMatcher.h"
#import "BKRPlayableScene.h"
#import "BKRRequestFrame.h"

@implementation BKRPlayheadMatcher

+ (id<BKRRequestMatching>)matcher {
    return [[self alloc] init];
}

- (BKRPlayableScene *)matchForRequest:(NSURLRequest *)request withPlayhead:(BKRPlayableScene *)playhead inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes {
    if ([playhead.originalRequest.URL.absoluteString isEqualToString:request.URL.absoluteString]) {
        return playhead;
    }
    return nil;
}

//- (BOOL)hasMatchForRequest:(NSURLRequest *)request withPlayheadIdentifier:(NSString *)playheadIdentifier inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes {
//    return YES;
//}
//
//- (BKRPlayableScene *)matchForRequest:(NSURLRequest *)request withPlayheadIdentifier:(NSString *)playheadIdentifier inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes {
//    return nil;
//}

@end
