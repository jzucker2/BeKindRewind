//
//  BKRPlayer.m
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import <OHHTTPStubs/OHHTTPStubs.h>
#import "BKRPlayer.h"
#import "BKRPlayableCassette.h"
#import "BKRPlayableRawFrame.h"
#import "BKRPlayableScene.h"
#import "BKROHHTTPStubsWrapper.h"

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
    return (NSArray<BKRPlayableScene *> *)self.currentCassette.allScenes;
}

- (void)_addStubs {
    __weak typeof(self) wself = self;
    __block BKRPlayableScene *matchedScene;
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        __strong typeof(wself) sself = wself;
        
        matchedScene = [self.matcher matchForRequest:request withPlayhead:sself.playheadScene inPlayableScenes:sself.scenes];
        // what happens if this increments past array? failure? handled in matching strictness enum?
        sself.playheadIndex++;
        return (matchedScene != nil);
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [BKROHHTTPStubsWrapper responseForScene:matchedScene];
    }];
}

- (void)_removeStubs {
    [BKROHHTTPStubsWrapper removeAllStubs];
}

- (BKRPlayableScene *)playheadScene {
    if (self.playheadIndex >= self.scenes.count) {
        return nil;
    }
    return [self.scenes objectAtIndex:self.playheadIndex];
}

- (void)setCurrentCassette:(BKRPlayableCassette *)currentCassette {
    if (currentCassette) {
        // This is for debugging purposes
        NSParameterAssert([currentCassette isKindOfClass:[BKRPlayableCassette class]]);
    }
    dispatch_barrier_async(self.playingQueue, ^{
        _currentCassette = currentCassette;
    });
}

@end
