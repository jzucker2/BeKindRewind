//
//  BKRPlayer.m
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import "BKRPlayer.h"
#import "BKRPlayableCassette.h"
#import "BKRPlayableRawFrame.h"
#import "BKRPlayableScene.h"
#import "BKROHHTTPStubsWrapper.h"
#import <OHHTTPStubs/OHHTTPStubs.h>

@interface BKRPlayer ()
@property (nonatomic) dispatch_queue_t playingQueue;
@property (nonatomic, copy) NSString *playheadUniqueIdentifier;
@property (nonatomic, weak, readonly) NSArray <BKRPlayableScene *> *scenes;
@property (nonatomic) NSUInteger playheadIndex;
@property (nonatomic, strong, readwrite) id<BKRRequestMatching>matcher;
@end

@implementation BKRPlayer

- (void)_init {
    _playingQueue = dispatch_queue_create("com.BKR.playing", DISPATCH_QUEUE_SERIAL);
    _playheadIndex = 0;
    _enabled = NO;
}

- (instancetype)initWithMatcherClass:(Class<BKRRequestMatching>)matcherClass {
    NSParameterAssert(matcherClass);
    self = [super init];
    if (self) {
        [self _init];
        _matcher = [matcherClass matcher];
    }
    return self;
}

+ (instancetype)playerWithMatcherClass:(Class<BKRRequestMatching>)matcherClass {
    return [[self alloc] initWithMatcherClass:matcherClass];
}

- (void)setEnabled:(BOOL)enabled {
    dispatch_barrier_sync(self.playingQueue, ^{
        if (enabled) {
            [self _addStubs];
        } else {
            [self _removeStubs];
        }
    });
    _enabled = enabled;
}

- (void)resetPlayhead {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.playingQueue, ^{
        __strong typeof(wself) sself = wself;
        sself.playheadIndex = 0;
    });
}

- (NSArray<BKRPlayableScene *> *)scenes {
    __block NSArray<BKRPlayableScene *> *playableScenes;
    dispatch_barrier_sync(self.playingQueue, ^{
        playableScenes = (NSArray<BKRPlayableScene *> *)self.currentCassette.allScenes;
    });
    return playableScenes;
}

- (void)_addStubs {
    __weak typeof(self) wself = self;
    [BKROHHTTPStubsWrapper stubRequestPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        __strong typeof(wself) sself = wself;
        return [sself _hasMatchForRequest:request];
    } withStubResponse:^BKRPlayableScene *(NSURLRequest * _Nonnull request) {
        NSLog(@"************************************************************");
        __strong typeof(wself) sself = wself;
        BKRPlayableScene *matchedScene = [sself _matchedPlayableSceneForRequest:request];
        [sself _incrementPlayheadIndex];
        return matchedScene;
    }];
}

- (void)dealloc {
    [self _removeStubs];
}

- (BKRPlayableScene *)_matchedPlayableSceneForRequest:(NSURLRequest *)request {
    return [self.matcher matchForRequest:request withPlayhead:self.playheadScene inPlayableScenes:self.scenes];
}

- (BOOL)_hasMatchForRequest:(NSURLRequest *)request {
    return YES;
}

- (void)_removeStubs {
    dispatch_barrier_async(self.playingQueue, ^{
        [BKROHHTTPStubsWrapper removeAllStubs];
    });
}

// does this need a dispatch barrier?
- (BKRPlayableScene *)playheadScene {
    if (self.playheadIndex >= self.scenes.count) {
        return nil;
    }
    return [self.scenes objectAtIndex:self.playheadIndex];
}

- (void)_incrementPlayheadIndex {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.playingQueue, ^{
        __strong typeof(wself) sself = wself;
        sself.playheadIndex++;
    });
}

- (void)setCurrentCassette:(BKRPlayableCassette *)currentCassette {
    if (currentCassette) {
        // This is for debugging purposes
        NSParameterAssert([currentCassette isKindOfClass:[BKRPlayableCassette class]]);
    }
    dispatch_barrier_sync(self.playingQueue, ^{
        _currentCassette = currentCassette;
    });
    [self resetPlayhead];
}

@end
