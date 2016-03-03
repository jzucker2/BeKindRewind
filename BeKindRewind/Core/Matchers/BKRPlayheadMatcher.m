//
//  BKRPlayheadMatcher.m
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import "BKRPlayheadMatcher.h"
#import "BKRScene+Playable.h"
#import "BKRRequestFrame.h"

@implementation BKRPlayheadMatcher

+ (id<BKRRequestMatching>)matcher {
    return [[self alloc] init];
}

// should also handle current request for everything, not just comparing to original request
- (BKRScene *)matchForRequest:(NSURLRequest *)request withCurrentSceneIndex:(NSUInteger)currentSceneIndex responseCount:(NSUInteger)currentResponseCount inPlayableScenes:(NSArray<BKRScene *> *)scenes {
    BKRScene *playhead = scenes[currentResponseCount];
    if ([playhead.originalRequest.URL.absoluteString isEqualToString:request.URL.absoluteString]) {
        return playhead;
    }
    return nil;
}

- (BOOL)hasMatchForRequest:(NSURLRequest *)request withCurrentSceneIndex:(NSUInteger)currentSceneIndex responseCount:(NSUInteger)currentResponseCount inPlayableScenes:(NSArray<BKRScene *> *)scenes {
    return YES;
}

- (BOOL)hasMatchForRequestHost:(NSString *)host withCurrentSceneIndex:(NSUInteger)currentSceneIndex responseCount:(NSUInteger)currentResponseCount inPlayableScenes:(NSArray<BKRScene *> *)scenes {
    BKRScene *playhead = scenes[currentResponseCount];
    return [host isEqualToString:playhead.originalRequest.requestHost];
}

- (BOOL)hasMatchForRequestScheme:(NSString *)scheme withCurrentSceneIndex:(NSUInteger)currentSceneIndex responseCount:(NSUInteger)currentResponseCount inPlayableScenes:(NSArray<BKRScene *> *)scenes {
    BKRScene *playhead = scenes[currentResponseCount];
    return [scheme isEqualToString:playhead.originalRequest.requestScheme];
}

- (BOOL)hasMatchForRequestPath:(NSString *)path withCurrentSceneIndex:(NSUInteger)currentSceneIndex responseCount:(NSUInteger)currentResponseCount inPlayableScenes:(NSArray<BKRScene *> *)scenes {
    BKRScene *playhead = scenes[currentResponseCount];
    NSString *playheadPath = playhead.originalRequest.requestPath;
    return [self _requestComponentString:path matchesSceneComponentString:playheadPath];
}

- (BOOL)hasMatchForRequestFragment:(NSString *)fragment withCurrentSceneIndex:(NSUInteger)currentSceneIndex responseCount:(NSUInteger)currentResponseCount inPlayableScenes:(NSArray<BKRScene *> *)scenes {
    BKRScene *playhead = scenes[currentResponseCount];
    NSString *playheadFragment = playhead.originalRequest.requestFragment;
    return [self _requestComponentString:fragment matchesSceneComponentString:playheadFragment];
}

- (BOOL)hasMatchForRequestQueryItems:(NSArray<NSURLQueryItem *> *)queryItems withCurrentSceneIndex:(NSUInteger)currentSceneIndex responseCount:(NSUInteger)currentResponseCount inPlayableScenes:(NSArray<BKRScene *> *)scenes {
    BKRScene *playhead = scenes[currentResponseCount];
    NSSet *requestQueryItemsSet = [NSSet setWithArray:queryItems];
    NSSet *playheadQueryItemsSet = [NSSet setWithArray:playhead.originalRequest.requestQueryItems];
    return [requestQueryItemsSet isEqualToSet:playheadQueryItemsSet];
}

- (BOOL)_requestComponentString:(NSString *)requestComponentString matchesSceneComponentString:(NSString *)sceneComponentString {
    if (
        requestComponentString &&
        sceneComponentString
        ) {
        return [requestComponentString isEqualToString:sceneComponentString];
    } else if ((requestComponentString && !sceneComponentString) ||
               (!requestComponentString && sceneComponentString)
               ) {
        return NO;
    }
    return YES;
}

@end
