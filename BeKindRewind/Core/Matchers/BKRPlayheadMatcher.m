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

- (BOOL)hasMatchForRequest:(NSURLRequest *)request withPlayhead:(BKRPlayableScene *)playhead inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes {
    return YES;
}

- (BOOL)hasMatchForRequestHost:(NSString *)host withPlayhead:(BKRPlayableScene *)playhead inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes {
    return [host isEqualToString:playhead.originalRequest.requestHost];
}

- (BOOL)hasMatchForRequestScheme:(NSString *)scheme withPlayhead:(BKRPlayableScene *)playhead inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes {
    return [scheme isEqualToString:playhead.originalRequest.requestScheme];
}

- (BOOL)hasMatchForRequestPath:(NSString *)path withPlayhead:(BKRPlayableScene *)playhead inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes {
    return [path isEqualToString:playhead.originalRequest.requestPath];
}

- (BOOL)hasMatchForRequestQueryItems:(NSArray<NSURLQueryItem *> *)queryItems withPlayhead:(BKRPlayableScene *)playhead inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes {
    NSSet *requestQueryItemsSet = [NSSet setWithArray:queryItems];
    NSSet *playheadQueryItemsSet = [NSSet setWithArray:playhead.originalRequest.requestQueryItems];
    return [requestQueryItemsSet isEqualToSet:playheadQueryItemsSet];
}

@end
