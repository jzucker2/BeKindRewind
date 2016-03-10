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
#import "BKRResponseStub.h"
#import "BKRPlayingContext.h"

@implementation BKRAnyMatcher

+ (id<BKRRequestMatching>)matcher {
    return [[self alloc] init];
}

- (BOOL)hasMatchForRequest:(NSURLRequest *)request withContext:(BKRPlayingContext *)context {
    BOOL hasMatch = NO;
    
    return YES;
}

- (BKRResponseStub *)matchForRequest:(NSURLRequest *)request withContext:(BKRPlayingContext *)context {
    return nil;
}

//// should also handle current request for everything, not just comparing to original request
//- (BKRScene *)matchForRequest:(NSURLRequest *)request withCurrentSceneIndex:(NSUInteger)currentSceneIndex responseCount:(NSUInteger)currentResponseCount inPlayableScenes:(NSArray<BKRScene *> *)scenes {
//    if (!request) {
//        return nil;
//    }
//    for (BKRScene *scene in scenes) {
//        if ([request.URL.absoluteString isEqualToString:scene.originalRequest.URL.absoluteString]) {
//            return scene;
//        }
//    }
//    return nil;
//}
//
//- (BOOL)hasMatchForRequest:(NSURLRequest *)request withCurrentSceneIndex:(NSUInteger)currentSceneIndex responseCount:(NSUInteger)currentResponseCount inPlayableScenes:(NSArray<BKRScene *> *)scenes {
//    return YES;
//}
//
//- (BOOL)hasMatchForRequestHost:(NSString *)host withCurrentSceneIndex:(NSUInteger)currentSceneIndex responseCount:(NSUInteger)currentResponseCount inPlayableScenes:(NSArray<BKRScene *> *)scenes {
//    if (!host) {
//        return YES;
//    }
//    for (BKRScene *scene in scenes) {
//        if ([host isEqualToString:scene.originalRequest.requestHost]) {
//            return YES;
//        }
//    }
//    return NO;
//}
//
//- (BOOL)hasMatchForRequestScheme:(NSString *)scheme withCurrentSceneIndex:(NSUInteger)currentSceneIndex responseCount:(NSUInteger)currentResponseCount inPlayableScenes:(NSArray<BKRScene *> *)scenes {
//    if (!scheme) {
//        return YES;
//    }
//    for (BKRScene *scene in scenes) {
//        if ([scheme isEqualToString:scene.originalRequest.requestScheme]) {
//            return YES;
//        }
//    }
//    return NO;
//}
//
//- (BOOL)hasMatchForRequestPath:(NSString *)path withCurrentSceneIndex:(NSUInteger)currentSceneIndex responseCount:(NSUInteger)currentResponseCount inPlayableScenes:(NSArray<BKRScene *> *)scenes {
//    if (!path) {
//        return YES;
//    }
//    for (BKRScene *scene in scenes) {
//        if ([path isEqualToString:scene.originalRequest.requestPath]) {
//            return YES;
//        }
//    }
//    return NO;
//}
//
//- (BOOL)hasMatchForRequestFragment:(NSString *)fragment withCurrentSceneIndex:(NSUInteger)currentSceneIndex responseCount:(NSUInteger)currentResponseCount inPlayableScenes:(NSArray<BKRScene *> *)scenes {
//    if (!fragment) {
//        return YES;
//    }
//    for (BKRScene *scene in scenes) {
//        if ([fragment isEqualToString:scene.originalRequest.requestFragment]) {
//            return YES;
//        }
//    }
//    return NO;
//}
//
//- (BOOL)hasMatchForRequestQueryItems:(NSArray<NSURLQueryItem *> *)queryItems withCurrentSceneIndex:(NSUInteger)currentSceneIndex responseCount:(NSUInteger)currentResponseCount inPlayableScenes:(NSArray<BKRScene *> *)scenes {
//    if (
//        !queryItems ||
//        !queryItems.count
//        ) {
//        return YES;
//    }
//    for (BKRScene *scene in scenes) {
//        NSSet *requestQueryItemsSet = [NSSet setWithArray:queryItems];
//        NSSet *playheadQueryItemsSet = [NSSet setWithArray:scene.originalRequest.requestQueryItems];
//        if ([requestQueryItemsSet isEqualToSet:playheadQueryItemsSet]) {
//            return YES;
//        }
//    }
//    return NO;
//}

@end
