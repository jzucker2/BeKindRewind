//
//  BKRPlayingEditor.m
//  Pods
//
//  Created by Jordan Zucker on 1/29/16.
//
//

#import "BKRPlayingEditor.h"
#import "BKROHHTTPStubsWrapper.h"
#import "BKRCassette+Playable.h"
#import "BKRScene+Playable.h"
#import "BKRConstants.h"

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
            [self _addStubsForMatcher:self.matcher forCassette:cassette withCompletionHandler:editingBlock];
        } else {
            [self _removeAllStubs];
            if (editingBlock) {
                editingBlock(updatedEnabled, cassette);
            }
        }

    }];
}

- (void)resetWithCompletionBlock:(void (^)(void))completionBlock {
    BKRWeakify(self);
    [super resetWithCompletionBlock:^void (void){
        BKRStrongify(self);
        if ([self->_matcher respondsToSelector:@selector(reset)]) {
            [self->_matcher reset];
        }
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)_removeAllStubs {
    [BKROHHTTPStubsWrapper removeAllStubs];
}

- (void)_addStubsForMatcher:(id<BKRRequestMatching>)matcher forCassette:(BKRCassette *)cassette withCompletionHandler:(BKRCassetteEditingBlock)completionBlock {
    NSArray<BKRScene *> *currentScenes = (NSArray<BKRScene *> *)cassette.allScenes;
    // reverse array: http://stackoverflow.com/questions/586370/how-can-i-reverse-a-nsarray-in-objective-c
    if (!currentScenes.count) {
        return;
    }
    __block NSUInteger responseCount = 0;
    // this is synchronous and blocking in this queue
    [currentScenes enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(BKRScene * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger currentSceneIndex = idx;
        NSLog(@"+++++++++++++++++++++++++++++++++");
        NSLog(@"currentSceneIndex: %lu", (unsigned long)currentSceneIndex);
        NSLog(@"start currentScenes iteration responseCount: %lu", (unsigned long)responseCount);
        [BKROHHTTPStubsWrapper stubRequestPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
            NSLog(@"=================================");
            NSLog(@"currentSceneIndex: %lu", (unsigned long)currentSceneIndex);
            NSLog(@"start test responseCount: %lu", (unsigned long)responseCount);
            BOOL finalTestResult = [matcher hasMatchForRequest:request withCurrentSceneIndex:currentSceneIndex responseCount:responseCount inPlayableScenes:currentScenes];
            if (!finalTestResult) {
                NSLog(@"return NO");
                return finalTestResult;
            }
            NSURLComponents *requestComponents = [NSURLComponents componentsWithString:request.URL.absoluteString];
            // does order matter? This is executed in the order of the NSURLComponents class header properties
            if ([matcher respondsToSelector:@selector(hasMatchForRequestScheme:withCurrentSceneIndex:responseCount:inPlayableScenes:)]) {
                finalTestResult = [matcher hasMatchForRequestScheme:requestComponents.scheme withCurrentSceneIndex:currentSceneIndex responseCount:responseCount inPlayableScenes:currentScenes];
                if (!finalTestResult) {
                    NSLog(@"return NO");
                    return finalTestResult;
                }
            }
            if ([matcher respondsToSelector:@selector(hasMatchForRequestUser:withCurrentSceneIndex:responseCount:inPlayableScenes:)]) {
                finalTestResult = [matcher hasMatchForRequestUser:requestComponents.user withCurrentSceneIndex:currentSceneIndex responseCount:responseCount inPlayableScenes:currentScenes];
                if (!finalTestResult) {
                    NSLog(@"return NO");
                    return finalTestResult;
                }
            }
            if ([matcher respondsToSelector:@selector(hasMatchForRequestPassword:withCurrentSceneIndex:responseCount:inPlayableScenes:)]) {
                finalTestResult = [matcher hasMatchForRequestPassword:requestComponents.password withCurrentSceneIndex:currentSceneIndex responseCount:responseCount inPlayableScenes:currentScenes];
                if (!finalTestResult) {
                    NSLog(@"return NO");
                    return finalTestResult;
                }
            }
            if ([matcher respondsToSelector:@selector(hasMatchForRequestHost:withCurrentSceneIndex:responseCount:inPlayableScenes:)]) {
                finalTestResult = [matcher hasMatchForRequestHost:requestComponents.host withCurrentSceneIndex:currentSceneIndex responseCount:responseCount inPlayableScenes:currentScenes];
                if (!finalTestResult) {
                    NSLog(@"return NO");
                    return finalTestResult;
                }
            }
            if ([matcher respondsToSelector:@selector(hasMatchForRequestPort:withCurrentSceneIndex:responseCount:inPlayableScenes:)]) {
                finalTestResult = [matcher hasMatchForRequestPort:requestComponents.port withCurrentSceneIndex:currentSceneIndex responseCount:responseCount inPlayableScenes:currentScenes];
                if (!finalTestResult) {
                    NSLog(@"return NO");
                    return finalTestResult;
                }
            }
            if ([matcher respondsToSelector:@selector(hasMatchForRequestPath:withCurrentSceneIndex:responseCount:inPlayableScenes:)]) {
                finalTestResult = [matcher hasMatchForRequestPath:requestComponents.path withCurrentSceneIndex:currentSceneIndex responseCount:responseCount inPlayableScenes:currentScenes];
                if (!finalTestResult) {
                    NSLog(@"return NO");
                    return finalTestResult;
                }
            }
            if ([matcher respondsToSelector:@selector(hasMatchForRequestQueryItems:withCurrentSceneIndex:responseCount:inPlayableScenes:)]) {
                finalTestResult = [matcher hasMatchForRequestQueryItems:requestComponents.queryItems withCurrentSceneIndex:currentSceneIndex responseCount:responseCount inPlayableScenes:currentScenes];
                if (!finalTestResult) {
                    NSLog(@"return NO");
                    return finalTestResult;
                }
            }
            if ([matcher respondsToSelector:@selector(hasMatchForRequestFragment:withCurrentSceneIndex:responseCount:inPlayableScenes:)]) {
                finalTestResult = [matcher hasMatchForRequestFragment:requestComponents.fragment withCurrentSceneIndex:currentSceneIndex responseCount:responseCount inPlayableScenes:currentScenes];
                if (!finalTestResult) {
                    NSLog(@"return NO");
                    return finalTestResult;
                }
            }
            NSLog(@"currentSceneIndex: %lu", (unsigned long)currentSceneIndex);
            NSLog(@"end test responseCount: %lu", (unsigned long)responseCount);
            NSLog(@"=================================");
            return finalTestResult;
        } withStubResponse:^BKRScene * _Nonnull(NSURLRequest * _Nonnull request) {
            // increment responseCount after passing it in
            NSLog(@"---------------------------------");
            NSLog(@"currentSceneIndex: %lu", (unsigned long)currentSceneIndex);
            NSLog(@"response responseCount: %lu", (unsigned long)responseCount);
            NSLog(@"---------------------------------");
            return [matcher matchForRequest:request withCurrentSceneIndex:currentSceneIndex responseCount:responseCount++ inPlayableScenes:currentScenes];
        }];
        NSLog(@"currentSceneIndex: %lu", (unsigned long)currentSceneIndex);
        NSLog(@"end currentScenes iteration responseCount: %lu", (unsigned long)responseCount);
        NSLog(@"+++++++++++++++++++++++++++++++++");
    }];
    NSLog(@"now completion block");
    // performed synchronously after above method
    if (completionBlock) {
        completionBlock(YES, cassette);
    }
}

@end
