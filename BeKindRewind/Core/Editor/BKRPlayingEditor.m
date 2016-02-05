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

- (void)addStubsForMatcher:(id<BKRRequestMatching>)matcher afterStubsBlock:(BKRAfterAddingStubs)afterStubsBlock {
    // reverse array: http://stackoverflow.com/questions/586370/how-can-i-reverse-a-nsarray-in-objective-c
    BKRPlayableCassette *stubbingCassette = (BKRPlayableCassette *)self.currentCassette;
    NSArray<BKRPlayableScene *> *currentScenes = (NSArray<BKRPlayableScene *> *)stubbingCassette.allScenes;
    dispatch_barrier_async(self.editingQueue, ^{
        __block NSUInteger callCount = 0;
        [currentScenes enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(BKRPlayableScene * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [BKROHHTTPStubsWrapper stubRequestPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
                BOOL finalTestResult = [matcher hasMatchForRequest:request withFirstMatchedIndex:idx currentNetworkCalls:callCount inPlayableScenes:currentScenes];
                if (!finalTestResult) {
                    return finalTestResult;
                }
                NSURLComponents *requestComponents = [NSURLComponents componentsWithString:request.URL.absoluteString];
                if ([matcher respondsToSelector:@selector(hasMatchForRequestScheme:withFirstMatchedIndex:currentNetworkCalls:inPlayableScenes:)]) {
                    finalTestResult = [matcher hasMatchForRequestScheme:requestComponents.scheme withFirstMatchedIndex:idx currentNetworkCalls:callCount inPlayableScenes:currentScenes];
                    if (!finalTestResult) {
                        return finalTestResult;
                    }
                }
                if ([matcher respondsToSelector:@selector(hasMatchForRequestHost:withFirstMatchedIndex:currentNetworkCalls:inPlayableScenes:)]) {
                    finalTestResult = [matcher hasMatchForRequestHost:requestComponents.host withFirstMatchedIndex:idx currentNetworkCalls:callCount inPlayableScenes:currentScenes];
                    if (!finalTestResult) {
                        return finalTestResult;
                    }
                }
                if ([matcher respondsToSelector:@selector(hasMatchForRequestPath:withFirstMatchedIndex:currentNetworkCalls:inPlayableScenes:)]) {
                    finalTestResult = [matcher hasMatchForRequestPath:requestComponents.path withFirstMatchedIndex:idx currentNetworkCalls:callCount inPlayableScenes:currentScenes];
                    if (!finalTestResult) {
                        return finalTestResult;
                    }
                }
                if ([matcher respondsToSelector:@selector(hasMatchForRequestQueryItems:withFirstMatchedIndex:currentNetworkCalls:inPlayableScenes:)]) {
                    finalTestResult = [matcher hasMatchForRequestQueryItems:requestComponents.queryItems withFirstMatchedIndex:idx currentNetworkCalls:callCount inPlayableScenes:currentScenes];
                    if (!finalTestResult) {
                        return finalTestResult;
                    }
                }
                return finalTestResult;
            } withStubResponse:^BKRPlayableScene * _Nonnull(NSURLRequest * _Nonnull request) {
                // check on this increment call to make sure it happens properly
                return [matcher matchForRequest:request withFirstMatchedIndex:idx currentNetworkCalls:callCount++ inPlayableScenes:currentScenes];
            }];
        }];
    });
    if (afterStubsBlock) {
        [stubbingCassette executeAfterAddingStubsBlock:afterStubsBlock];
    }
}

- (void)_removeStubs {
    dispatch_barrier_async(self.editingQueue, ^{
        [BKROHHTTPStubsWrapper removeAllStubs];
    });
}

@end
