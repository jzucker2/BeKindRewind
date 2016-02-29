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
- (BKRScene *)matchForRequest:(NSURLRequest *)request withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRScene *> *)scenes {
    BKRScene *playhead = scenes[networkCalls];
    if ([playhead.originalRequest.URL.absoluteString isEqualToString:request.URL.absoluteString]) {
        return playhead;
    }
    return nil;
}

- (BOOL)hasMatchForRequest:(NSURLRequest *)request withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRScene *> *)scenes {
    return YES;
}

- (BOOL)hasMatchForRequestHost:(NSString *)host withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRScene *> *)scenes {
    BKRScene *playhead = scenes[networkCalls];
    return [host isEqualToString:playhead.originalRequest.requestHost];
}

- (BOOL)hasMatchForRequestScheme:(NSString *)scheme withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRScene *> *)scenes {
    BKRScene *playhead = scenes[networkCalls];
    return [scheme isEqualToString:playhead.originalRequest.requestScheme];
}

- (BOOL)hasMatchForRequestPath:(NSString *)path withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRScene *> *)scenes {
    BKRScene *playhead = scenes[networkCalls];
    NSString *playheadPath = playhead.originalRequest.requestPath;
    return [self _requestComponentString:path matchesSceneComponentString:playheadPath];
}

- (BOOL)hasMatchForRequestFragment:(NSString *)fragment withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRScene *> *)scenes {
    BKRScene *playhead = scenes[networkCalls];
    NSString *playheadFragment = playhead.originalRequest.requestFragment;
    return [self _requestComponentString:fragment matchesSceneComponentString:playheadFragment];
}

- (BOOL)hasMatchForRequestQueryItems:(NSArray<NSURLQueryItem *> *)queryItems withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRScene *> *)scenes {
    BKRScene *playhead = scenes[networkCalls];
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
