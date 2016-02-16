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
#import "BKRScene+Playable.h"

@interface BKRPlayingEditor ()
@end

@implementation BKRPlayingEditor

@synthesize matcher = _matcher;

- (instancetype)initWithMatcher:(id<BKRRequestMatching>)matcher {
    self = [super init];
    if (self) {
        _matcher = matcher;
    }
    return self;
}

+ (instancetype)editorWithMatcher:(id<BKRRequestMatching>)matcher {
    return [[self alloc] initWithMatcher:matcher];
}

- (void)setEnabled:(BOOL)enabled {
    [self setEnabled:enabled withCompletionHandler:nil];
}

- (void)setEnabled:(BOOL)enabled withCompletionHandler:(BKRCassetteEditingBlock)editingBlock {
    BKRWeakify(self);
    [super setEnabled:enabled withCompletionHandler:^void(BOOL updatedEnabled, BKRCassette *cassette) {
        BKRStrongify(self);
        if (updatedEnabled) {
            BKRPlayableCassette *stubbingCassette = (BKRPlayableCassette *)cassette;
            NSArray<BKRScene *> *currentScenes = (NSArray<BKRScene *> *)stubbingCassette.allScenes;
            NSDate *now = [NSDate date];
            NSLog(@"%s", __PRETTY_FUNCTION__);
            NSLog(@"now: %@ stubbingCassette: %@", now, stubbingCassette);
            NSLog(@"now: %@ currentScenes: %@", now, currentScenes);
//            [self _addStubsForMatcherWithScenes:currentScenes withCompletionHandler:editingBlock enabled:updatedEnabled cassette:cassette];
            [self _addStubsForMatcher:self.matcher forCassette:stubbingCassette withCompletionHandler:editingBlock];
        } else {
            [self _removeAllStubs];
            if (editingBlock) {
                editingBlock(updatedEnabled, cassette);
            }
        }

    }];
}

//- (void)setEnabled:(BOOL)enabled withCompletionHandler:(void (^)(void))completionBlock {
//    [super setEnabled:enabled withCompletionHandler:nil];
//    if (enabled) {
//        [self addStubsForMatcher];
//    } else {
//        [self removeAllStubs];
//    }
//    if (completionBlock) {
//        if ([NSThread isMainThread]) {
//            completionBlock();
//        } else {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                completionBlock();
//            });
//        }
//    }
//}

- (void)_removeAllStubs {
    [BKROHHTTPStubsWrapper removeAllStubs];
//    dispatch_barrier_async(self.editingQueue, ^{
//        [BKROHHTTPStubsWrapper removeAllStubs];
//    });
}

- (void)_addStubsForMatcher:(id<BKRRequestMatching>)matcher forCassette:(BKRPlayableCassette *)cassette withCompletionHandler:(BKRCassetteEditingBlock)completionBlock {
    NSArray<BKRScene *> *currentScenes = (NSArray<BKRScene *> *)cassette.allScenes;
    NSDate *now = [NSDate date];
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"now: %@ cassette: %@", now, cassette);
    NSLog(@"now: %@ currentScenes: %@", now, currentScenes);
    // reverse array: http://stackoverflow.com/questions/586370/how-can-i-reverse-a-nsarray-in-objective-c
    if (!currentScenes.count) {
        return;
    }
    __block NSUInteger callCount = 0;
    [currentScenes enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(BKRScene * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
        } withStubResponse:^BKRScene * _Nonnull(NSURLRequest * _Nonnull request) {
            // check on this increment call to make sure it happens properly
            return [matcher matchForRequest:request withFirstMatchedIndex:idx currentNetworkCalls:callCount++ inPlayableScenes:currentScenes];
        }];
    }];
    if (completionBlock) {
        completionBlock(YES, cassette);
    }
}

//- (void)_addStubsForMatcherWithScenes:(NSArray<BKRScene *> *)scenes withCompletionHandler:(BKRCassetteEditingBlock)completionBlock enabled:(BOOL)currentEnabled cassette:(BKRCassette *)cassette {
//    [self _addStubsForMatcherForMatcher:self.matcher withScenes:scenes enabled:currentEnabled cassette:cassette andCompletionHandler:completionBlock];
//}
//
//- (void)_addStubsForMatcherForMatcher:(id<BKRRequestMatching>)matcher withScenes:(NSArray<BKRScene *> *)scenes enabled:(BOOL)enabled cassette:(BKRCassette *)cassette andCompletionHandler:(BKRCassetteEditingBlock)completionBlock {
//    // reverse array: http://stackoverflow.com/questions/586370/how-can-i-reverse-a-nsarray-in-objective-c
//    if (!scenes.count) {
//        return;
//    }
//    __block NSUInteger callCount = 0;
//    [scenes enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(BKRScene * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [BKROHHTTPStubsWrapper stubRequestPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
//            BOOL finalTestResult = [matcher hasMatchForRequest:request withFirstMatchedIndex:idx currentNetworkCalls:callCount inPlayableScenes:scenes];
//            if (!finalTestResult) {
//                return finalTestResult;
//            }
//            NSURLComponents *requestComponents = [NSURLComponents componentsWithString:request.URL.absoluteString];
//            if ([matcher respondsToSelector:@selector(hasMatchForRequestScheme:withFirstMatchedIndex:currentNetworkCalls:inPlayableScenes:)]) {
//                finalTestResult = [matcher hasMatchForRequestScheme:requestComponents.scheme withFirstMatchedIndex:idx currentNetworkCalls:callCount inPlayableScenes:scenes];
//                if (!finalTestResult) {
//                    return finalTestResult;
//                }
//            }
//            if ([matcher respondsToSelector:@selector(hasMatchForRequestHost:withFirstMatchedIndex:currentNetworkCalls:inPlayableScenes:)]) {
//                finalTestResult = [matcher hasMatchForRequestHost:requestComponents.host withFirstMatchedIndex:idx currentNetworkCalls:callCount inPlayableScenes:scenes];
//                if (!finalTestResult) {
//                    return finalTestResult;
//                }
//            }
//            if ([matcher respondsToSelector:@selector(hasMatchForRequestPath:withFirstMatchedIndex:currentNetworkCalls:inPlayableScenes:)]) {
//                finalTestResult = [matcher hasMatchForRequestPath:requestComponents.path withFirstMatchedIndex:idx currentNetworkCalls:callCount inPlayableScenes:scenes];
//                if (!finalTestResult) {
//                    return finalTestResult;
//                }
//            }
//            if ([matcher respondsToSelector:@selector(hasMatchForRequestQueryItems:withFirstMatchedIndex:currentNetworkCalls:inPlayableScenes:)]) {
//                finalTestResult = [matcher hasMatchForRequestQueryItems:requestComponents.queryItems withFirstMatchedIndex:idx currentNetworkCalls:callCount inPlayableScenes:scenes];
//                if (!finalTestResult) {
//                    return finalTestResult;
//                }
//            }
//            return finalTestResult;
//        } withStubResponse:^BKRScene * _Nonnull(NSURLRequest * _Nonnull request) {
//            // check on this increment call to make sure it happens properly
//            return [matcher matchForRequest:request withFirstMatchedIndex:idx currentNetworkCalls:callCount++ inPlayableScenes:scenes];
//        }];
//    }];
//    if (completionBlock) {
//        completionBlock(enabled, cassette);
//    }
//}

@end
