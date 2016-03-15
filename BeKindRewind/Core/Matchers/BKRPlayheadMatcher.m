//
//  BKRPlayheadMatcher.m
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import "BKRPlayheadMatcher.h"
//#import "BKRScene+Playable.h"
//#import "BKRScene+Playable.h"
////#import "BKRRequestFrame.h"
//#import "BKRPlayingContext.h"
//#import "BKRResponseStub.h"

@implementation BKRPlayheadMatcher

+ (id<BKRRequestMatching>)matcher {
    return [[self alloc] init];
}

- (BOOL)hasMatchForRequest:(NSURLRequest *)request withPlayhead:(BKRPlayhead *)playhead {
    return ([self matchForRequest:request withPlayhead:playhead] != nil);
}

- (BKRResponseStub *)matchForRequest:(NSURLRequest *)request withPlayhead:(BKRPlayhead *)playhead {
//    BKRScene *scene = context.allItems[0].scene;
//    BKRResponseStub *stub = nil;
//    if (scene.responseError) {
//        stub = [BKRResponseStub responseWithError:scene.responseError];
//    } else {
//        stub = [BKRResponseStub responseWithData:scene.responseData statusCode:(int)scene.responseStatusCode headers:scene.responseHeaders];
//    }
    
//    return scene.finalResponseStub;
    BKRResponseStub *responseStub = nil;
    for (BKRPlayheadItem *item in playhead.incompleteItems) {
        NSLog(@"item: %@", item);
        BKRScene *scene = item.scene;
        if ([scene hasResponseForRequest:request]) {
            if (
                item.redirectsRemaining &&
                [scene hasRedirectResponseStubForRequest:request]
                ) {
                responseStub = [scene responseStubForRedirect:item.redirectsRemaining];
            } else if ([scene hasFinalResponseStubForRequest:request]) {
                responseStub = [scene finalResponseStub];
            }
        }
    }
    return responseStub;
}

//// should also handle current request for everything, not just comparing to original request
//- (BKRScene *)matchForRequest:(NSURLRequest *)request withCurrentSceneIndex:(NSUInteger)currentSceneIndex responseCount:(NSUInteger)currentResponseCount inPlayableScenes:(NSArray<BKRScene *> *)scenes {
//    NSLog(@"%s request (%@) currentSceneIndex (%lu) responseCount (%lu) scenes (%@)", __PRETTY_FUNCTION__, request, (unsigned long)currentSceneIndex, (unsigned long)currentResponseCount, scenes);
//    BKRScene *playhead = scenes[currentSceneIndex];
//    if ([playhead.originalRequest.URL.absoluteString isEqualToString:request.URL.absoluteString]) {
//        NSLog(@"%s return %@", __PRETTY_FUNCTION__, playhead.debugDescription);
//        return playhead;
//    }
//    return nil;
//}
//
//- (BOOL)hasMatchForRequest:(NSURLRequest *)request withCurrentSceneIndex:(NSUInteger)currentSceneIndex responseCount:(NSUInteger)currentResponseCount inPlayableScenes:(NSArray<BKRScene *> *)scenes {
//    NSLog(@"%s request (%@) currentSceneIndex (%lu) responseCount (%lu) scenes (%@)", __PRETTY_FUNCTION__, request, (unsigned long)currentSceneIndex, (unsigned long)currentResponseCount, scenes);
//    return YES;
//}
//
//- (BOOL)hasMatchForRequestHost:(NSString *)host withCurrentSceneIndex:(NSUInteger)currentSceneIndex responseCount:(NSUInteger)currentResponseCount inPlayableScenes:(NSArray<BKRScene *> *)scenes {
//    BKRScene *playhead = scenes[currentSceneIndex];
//    return [host isEqualToString:playhead.originalRequest.requestHost];
//}
//
//- (BOOL)hasMatchForRequestScheme:(NSString *)scheme withCurrentSceneIndex:(NSUInteger)currentSceneIndex responseCount:(NSUInteger)currentResponseCount inPlayableScenes:(NSArray<BKRScene *> *)scenes {
//    BKRScene *playhead = scenes[currentSceneIndex];
//    return [scheme isEqualToString:playhead.originalRequest.requestScheme];
//}
//
//- (BOOL)hasMatchForRequestPath:(NSString *)path withCurrentSceneIndex:(NSUInteger)currentSceneIndex responseCount:(NSUInteger)currentResponseCount inPlayableScenes:(NSArray<BKRScene *> *)scenes {
//    BKRScene *playhead = scenes[currentSceneIndex];
//    NSString *playheadPath = playhead.originalRequest.requestPath;
//    return [self _requestComponentString:path matchesSceneComponentString:playheadPath];
//}
//
//- (BOOL)hasMatchForRequestFragment:(NSString *)fragment withCurrentSceneIndex:(NSUInteger)currentSceneIndex responseCount:(NSUInteger)currentResponseCount inPlayableScenes:(NSArray<BKRScene *> *)scenes {
//    BKRScene *playhead = scenes[currentSceneIndex];
//    NSString *playheadFragment = playhead.originalRequest.requestFragment;
//    return [self _requestComponentString:fragment matchesSceneComponentString:playheadFragment];
//}
//
//- (BOOL)hasMatchForRequestQueryItems:(NSArray<NSURLQueryItem *> *)queryItems withCurrentSceneIndex:(NSUInteger)currentSceneIndex responseCount:(NSUInteger)currentResponseCount inPlayableScenes:(NSArray<BKRScene *> *)scenes {
//    BKRScene *playhead = scenes[currentSceneIndex];
//    NSSet *requestQueryItemsSet = [NSSet setWithArray:queryItems];
//    NSSet *playheadQueryItemsSet = [NSSet setWithArray:playhead.originalRequest.requestQueryItems];
//    return [requestQueryItemsSet isEqualToSet:playheadQueryItemsSet];
//}

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
