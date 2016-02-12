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

@synthesize beforeAddingStubsBlock = _beforeAddingStubsBlock;
@synthesize afterAddingStubsBlock = _afterAddingStubsBlock;

- (void)setBeforeAddingStubsBlock:(BKRBeforeAddingStubs)beforeAddingStubsBlock {
    BKRWeakify(self);
    dispatch_barrier_async(self.editingQueue, ^{
        BKRStrongify(self);
        self->_beforeAddingStubsBlock = beforeAddingStubsBlock;
    });
}

- (BKRBeforeAddingStubs)beforeAddingStubsBlock {
    __block BKRBeforeAddingStubs stubsBlock = nil;
    BKRWeakify(self);
    dispatch_sync(self.editingQueue, ^{
        BKRStrongify(self);
        stubsBlock = self->_beforeAddingStubsBlock;
    });
    return stubsBlock;
}

- (void)setAfterAddingStubsBlock:(BKRAfterAddingStubs)afterAddingStubsBlock {
    BKRWeakify(self);
    dispatch_barrier_async(self.editingQueue, ^{
        BKRStrongify(self);
        self->_afterAddingStubsBlock = afterAddingStubsBlock;
    });
    
}

- (BKRAfterAddingStubs)afterAddingStubsBlock {
    __block BKRAfterAddingStubs stubsBlock = nil;
    BKRWeakify(self);
    dispatch_sync(self.editingQueue, ^{
        BKRStrongify(self);
        stubsBlock = self->_afterAddingStubsBlock;
    });
    return stubsBlock;
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    dispatch_barrier_async(self.editingQueue, ^{
        [BKROHHTTPStubsWrapper setEnabled:enabled];
    });
}

- (void)removeAllStubs {
    [self _removeStubs];
}

- (void)addStubsForMatcher:(id<BKRRequestMatching>)matcher {
    // make sure this executes on the main thread
    BKRBeforeAddingStubs currentBeforeAddingStubsBlock = self.beforeAddingStubsBlock;
    if (currentBeforeAddingStubsBlock) {
        if ([NSThread isMainThread]) {
            currentBeforeAddingStubsBlock();
        } else {
            // if player is called from a background queue, make sure this happens on main queue
            dispatch_async(dispatch_get_main_queue(), ^{
                currentBeforeAddingStubsBlock();
            });
        }
    }

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
    if (self.afterAddingStubsBlock) {
        [stubbingCassette executeAfterAddingStubsBlock:self.afterAddingStubsBlock];
    }
}

- (void)_removeStubs {
    dispatch_barrier_async(self.editingQueue, ^{
        [BKROHHTTPStubsWrapper removeAllStubs];
    });
}



@end
