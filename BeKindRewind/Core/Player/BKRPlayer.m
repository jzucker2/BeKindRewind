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

@interface BKRPlayer ()
@property (nonatomic) dispatch_queue_t playingQueue;
@property (nonatomic, copy) NSString *playheadUniqueIdentifier;
@property (nonatomic, weak, readonly) NSArray <BKRPlayableScene *> *scenes;
@property (nonatomic) NSUInteger playheadIndex;
@property (nonatomic, strong, readwrite) id<BKRRequestMatching>matcher;
@property (nonatomic, strong, readonly) BKRStubsTestBlock testBlock;
@property (nonatomic, strong, readonly) BKRStubsResponseBlock responseBlock;
@end

@implementation BKRPlayer
@synthesize testBlock = _testBlock;
@synthesize responseBlock = _responseBlock;

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

- (BKRStubsTestBlock)testBlock {
    if (!_testBlock) {
        __strong typeof(self) wself = self;
        _testBlock = ^BOOL(NSURLRequest *request){
            __weak typeof(wself) sself = wself;
            BOOL finalTestResult = [sself.matcher hasMatchForRequest:request withPlayhead:sself.playheadScene inPlayableScenes:sself.scenes];
            if (!finalTestResult) {
                return finalTestResult;
            }
            NSURLComponents *requestComponents = [NSURLComponents componentsWithString:request.URL.absoluteString];
            if ([sself.matcher respondsToSelector:@selector(hasMatchForRequestScheme:withPlayhead:inPlayableScenes:)]) {
                finalTestResult = [sself.matcher hasMatchForRequestScheme:requestComponents.scheme withPlayhead:sself.playheadScene inPlayableScenes:sself.scenes];
                if (!finalTestResult) {
                    return finalTestResult;
                }
            }
            if ([sself.matcher respondsToSelector:@selector(hasMatchForRequestHost:withPlayhead:inPlayableScenes:)]) {
                finalTestResult = [sself.matcher hasMatchForRequestHost:requestComponents.host withPlayhead:sself.playheadScene inPlayableScenes:sself.scenes];
                if (!finalTestResult) {
                    return finalTestResult;
                }
            }
            if ([sself.matcher respondsToSelector:@selector(hasMatchForRequestPath:withPlayhead:inPlayableScenes:)]) {
                finalTestResult = [sself.matcher hasMatchForRequestPath:requestComponents.path withPlayhead:sself.playheadScene inPlayableScenes:sself.scenes];
                if (!finalTestResult) {
                    return finalTestResult;
                }
            }
            if ([sself.matcher respondsToSelector:@selector(hasMatchForRequestQueryItems:withPlayhead:inPlayableScenes:)]) {
                finalTestResult = [sself.matcher hasMatchForRequestQueryItems:requestComponents.queryItems withPlayhead:sself.playheadScene inPlayableScenes:sself.scenes];
                if (!finalTestResult) {
                    return finalTestResult;
                }
            }
            return finalTestResult;
        };
    }
    return _testBlock;
}

- (BKRStubsResponseBlock)responseBlock {
    if (!_responseBlock) {
        __strong typeof(self) wself = self;
        _responseBlock = ^BKRPlayableScene*(NSURLRequest *request){
            __weak typeof(wself) sself = wself;
            BKRPlayableScene *matchedScene = [sself.matcher matchForRequest:request withPlayhead:sself.playheadScene inPlayableScenes:sself.scenes];
            [sself _incrementPlayheadIndex];
            return matchedScene;
        };
    }
    return _responseBlock;
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
    [BKROHHTTPStubsWrapper stubRequestPassingTest:self.testBlock withStubResponse:self.responseBlock];
}

- (void)dealloc {
    [self _removeStubs];
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
