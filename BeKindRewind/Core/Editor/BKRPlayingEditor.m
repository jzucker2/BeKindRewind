//
//  BKRPlayingEditor.m
//  Pods
//
//  Created by Jordan Zucker on 1/29/16.
//
//

#import "BKRPlayingEditor.h"
#import "BKROHHTTPStubsWrapper.h"
#import "BKRPlayableCassette.h"
#import "BKRPlayableScene.h"

@implementation BKRPlayingEditor

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    dispatch_barrier_async(self.editingQueue, ^{
        [BKROHHTTPStubsWrapper setEnabled:enabled];
    });
}

- (void)addStubsForMatcher:(id<BKRRequestMatching>)matcher {
//    __weak typeof(self) wself = self;
    // reverse array: http://stackoverflow.com/questions/586370/how-can-i-reverse-a-nsarray-in-objective-c
    NSArray<BKRPlayableScene *> *currentScenes = (NSArray<BKRPlayableScene *> *)self.currentCassette.allScenes;
    dispatch_barrier_async(self.editingQueue, ^{
//        __weak typeof (wself) sself = wself;
        __block NSUInteger callCount = 0;
        [currentScenes enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(BKRPlayableScene * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [BKROHHTTPStubsWrapper stubRequestPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
                BOOL finalTestResult = [matcher hasMatchForRequest:request withPlayhead:obj inPlayableScenes:currentScenes];
                if (!finalTestResult) {
                    return finalTestResult;
                }
                NSURLComponents *requestComponents = [NSURLComponents componentsWithString:request.URL.absoluteString];
                if ([matcher respondsToSelector:@selector(hasMatchForRequestScheme:withPlayhead:inPlayableScenes:)]) {
                    finalTestResult = [matcher hasMatchForRequestScheme:requestComponents.scheme withPlayhead:obj inPlayableScenes:currentScenes];
                    if (!finalTestResult) {
                        return finalTestResult;
                    }
                }
                if ([matcher respondsToSelector:@selector(hasMatchForRequestHost:withPlayhead:inPlayableScenes:)]) {
                    finalTestResult = [matcher hasMatchForRequestHost:requestComponents.host withPlayhead:obj inPlayableScenes:currentScenes];
                    if (!finalTestResult) {
                        return finalTestResult;
                    }
                }
                if ([matcher respondsToSelector:@selector(hasMatchForRequestPath:withPlayhead:inPlayableScenes:)]) {
                    finalTestResult = [matcher hasMatchForRequestPath:requestComponents.path withPlayhead:obj inPlayableScenes:currentScenes];
                    if (!finalTestResult) {
                        return finalTestResult;
                    }
                }
                if ([matcher respondsToSelector:@selector(hasMatchForRequestQueryItems:withPlayhead:inPlayableScenes:)]) {
                    finalTestResult = [matcher hasMatchForRequestQueryItems:requestComponents.queryItems withPlayhead:obj inPlayableScenes:currentScenes];
                    if (!finalTestResult) {
                        return finalTestResult;
                    }
                }
                return finalTestResult;
            } withStubResponse:^BKRPlayableScene * _Nonnull(NSURLRequest * _Nonnull request) {
                BKRPlayableScene *matchedScene = [matcher matchForRequest:request withPlayhead:obj inPlayableScenes:currentScenes];
                callCount++;
                return matchedScene;
            }];
        }];
//        for (NSUInteger i=0; i < currentScenes.count; i++) {
//            BKRPlayableScene *stubbingScene = [currentScenes objectAtIndex:i];
//            [BKROHHTTPStubsWrapper stubRequestPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
//                BOOL finalTestResult = [matcher hasMatchForRequest:request withPlayhead:stubbingScene inPlayableScenes:currentScenes];
//                if (!finalTestResult) {
//                    return finalTestResult;
//                }
//                NSURLComponents *requestComponents = [NSURLComponents componentsWithString:request.URL.absoluteString];
//                if ([matcher respondsToSelector:@selector(hasMatchForRequestScheme:withPlayhead:inPlayableScenes:)]) {
//                    finalTestResult = [matcher hasMatchForRequestScheme:requestComponents.scheme withPlayhead:stubbingScene inPlayableScenes:currentScenes];
//                    if (!finalTestResult) {
//                        return finalTestResult;
//                    }
//                }
//                if ([matcher respondsToSelector:@selector(hasMatchForRequestHost:withPlayhead:inPlayableScenes:)]) {
//                    finalTestResult = [matcher hasMatchForRequestHost:requestComponents.host withPlayhead:stubbingScene inPlayableScenes:currentScenes];
//                    if (!finalTestResult) {
//                        return finalTestResult;
//                    }
//                }
//                if ([matcher respondsToSelector:@selector(hasMatchForRequestPath:withPlayhead:inPlayableScenes:)]) {
//                    finalTestResult = [matcher hasMatchForRequestPath:requestComponents.path withPlayhead:stubbingScene inPlayableScenes:currentScenes];
//                    if (!finalTestResult) {
//                        return finalTestResult;
//                    }
//                }
//                if ([matcher respondsToSelector:@selector(hasMatchForRequestQueryItems:withPlayhead:inPlayableScenes:)]) {
//                    finalTestResult = [matcher hasMatchForRequestQueryItems:requestComponents.queryItems withPlayhead:stubbingScene inPlayableScenes:currentScenes];
//                    if (!finalTestResult) {
//                        return finalTestResult;
//                    }
//                }
//                return finalTestResult;
//            } withStubResponse:^BKRPlayableScene * _Nonnull(NSURLRequest * _Nonnull request) {
//                return [matcher matchForRequest:request withPlayhead:stubbingScene inPlayableScenes:currentScenes];
//            }];
//        }
    });
}

- (void)_removeStubs {
    dispatch_barrier_async(self.editingQueue, ^{
        [BKROHHTTPStubsWrapper removeAllStubs];
    });
}

@end
