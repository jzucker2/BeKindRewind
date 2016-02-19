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

- (void)_removeAllStubs {
    [BKROHHTTPStubsWrapper removeAllStubs];
}

- (void)_addStubsForMatcher:(id<BKRRequestMatching>)matcher forCassette:(BKRCassette *)cassette withCompletionHandler:(BKRCassetteEditingBlock)completionBlock {
    NSArray<BKRScene *> *currentScenes = (NSArray<BKRScene *> *)cassette.allScenes;
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

@end
