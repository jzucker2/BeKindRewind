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
    NSArray<BKRPlayableScene *> *currentScenes = (NSArray<BKRPlayableScene *> *)self.currentCassette.allScenes;
    dispatch_barrier_async(self.editingQueue, ^{
//        __weak typeof (wself) sself = wself;
        for (BKRPlayableScene *stubbingScene in currentScenes) {
            [BKROHHTTPStubsWrapper stubRequestPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
                BOOL finalTestResult = [matcher hasMatchForRequest:request withPlayhead:stubbingScene inPlayableScenes:currentScenes];
                if (!finalTestResult) {
                    return finalTestResult;
                }
                NSURLComponents *requestComponents = [NSURLComponents componentsWithString:request.URL.absoluteString];
                if ([matcher respondsToSelector:@selector(hasMatchForRequestScheme:withPlayhead:inPlayableScenes:)]) {
                    finalTestResult = [matcher hasMatchForRequestScheme:requestComponents.scheme withPlayhead:stubbingScene inPlayableScenes:currentScenes];
                    if (!finalTestResult) {
                        return finalTestResult;
                    }
                }
                if ([matcher respondsToSelector:@selector(hasMatchForRequestHost:withPlayhead:inPlayableScenes:)]) {
                    finalTestResult = [matcher hasMatchForRequestHost:requestComponents.host withPlayhead:stubbingScene inPlayableScenes:currentScenes];
                    if (!finalTestResult) {
                        return finalTestResult;
                    }
                }
                if ([matcher respondsToSelector:@selector(hasMatchForRequestPath:withPlayhead:inPlayableScenes:)]) {
                    finalTestResult = [matcher hasMatchForRequestPath:requestComponents.path withPlayhead:stubbingScene inPlayableScenes:currentScenes];
                    if (!finalTestResult) {
                        return finalTestResult;
                    }
                }
                if ([matcher respondsToSelector:@selector(hasMatchForRequestQueryItems:withPlayhead:inPlayableScenes:)]) {
                    finalTestResult = [matcher hasMatchForRequestQueryItems:requestComponents.queryItems withPlayhead:stubbingScene inPlayableScenes:currentScenes];
                    if (!finalTestResult) {
                        return finalTestResult;
                    }
                }
                return finalTestResult;
            } withStubResponse:^BKRPlayableScene * _Nonnull(NSURLRequest * _Nonnull request) {
                return [matcher matchForRequest:request withPlayhead:stubbingScene inPlayableScenes:currentScenes];
            }];
        }
    });
}

- (void)_removeStubs {
    dispatch_barrier_async(self.editingQueue, ^{
        [BKROHHTTPStubsWrapper removeAllStubs];
    });
}

@end
