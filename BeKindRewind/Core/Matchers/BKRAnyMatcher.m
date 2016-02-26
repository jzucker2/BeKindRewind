//
//  BKRAnyMatcher.m
//  Pods
//
//  Created by Jordan Zucker on 2/25/16.
//
//

#import "BKRAnyMatcher.h"
#import "BKRScene+Playable.h"
#import "BKRRequestFrame.h"

@implementation BKRAnyMatcher

+ (id<BKRRequestMatching>)matcher {
    return [[self alloc] init];
}

// should also handle current request for everything, not just comparing to original request
- (BKRScene *)matchForRequest:(NSURLRequest *)request withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRScene *> *)scenes {
    if (!request) {
        return nil;
    }
    for (BKRScene *scene in scenes) {
        if ([request.URL.absoluteString isEqualToString:scene.originalRequest.URL.absoluteString]) {
            return scene;
        }
    }
    return nil;
}

- (BOOL)hasMatchForRequest:(NSURLRequest *)request withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRScene *> *)scenes {
    return YES;
}

- (BOOL)hasMatchForRequestHost:(NSString *)host withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRScene *> *)scenes {
    if (!host) {
        return YES;
    }
    for (BKRScene *scene in scenes) {
        if ([host isEqualToString:scene.originalRequest.requestHost]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasMatchForRequestScheme:(NSString *)scheme withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRScene *> *)scenes {
    if (!scheme) {
        return YES;
    }
    for (BKRScene *scene in scenes) {
        if ([scheme isEqualToString:scene.originalRequest.requestScheme]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasMatchForRequestPath:(NSString *)path withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRScene *> *)scenes {
    if (!path) {
        return YES;
    }
    for (BKRScene *scene in scenes) {
        if ([path isEqualToString:scene.originalRequest.requestPath]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasMatchForRequestFragment:(NSString *)fragment withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRScene *> *)scenes {
    if (!fragment) {
        return YES;
    }
    for (BKRScene *scene in scenes) {
        if ([fragment isEqualToString:scene.originalRequest.requestFragment]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasMatchForRequestQueryItems:(NSArray<NSURLQueryItem *> *)queryItems withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRScene *> *)scenes {
    if (
        !queryItems ||
        !queryItems.count
        ) {
        return YES;
    }
    for (BKRScene *scene in scenes) {
        NSSet *requestQueryItemsSet = [NSSet setWithArray:queryItems];
        NSSet *playheadQueryItemsSet = [NSSet setWithArray:scene.originalRequest.requestQueryItems];
        if ([requestQueryItemsSet isEqualToSet:playheadQueryItemsSet]) {
            return YES;
        }
    }
    return NO;
}

@end
