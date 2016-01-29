//
//  BKRPlayer.m
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import "BKRCassetteHandler.h"
#import "BKRPlayer.h"
#import "BKRPlayableCassette.h"
#import "BKRPlayableRawFrame.h"
#import "BKRPlayableScene.h"
#import "BKROHHTTPStubsWrapper.h"

@interface BKRPlayer ()
@property (nonatomic, strong) BKRCassetteHandler *cassetteHandler;
//@property (nonatomic) dispatch_queue_t playingQueue;
//@property (nonatomic, copy) NSString *playheadUniqueIdentifier;
//@property (nonatomic, weak, readonly) NSArray <BKRPlayableScene *> *scenes;
@property (nonatomic) NSUInteger playheadIndex;
@property (nonatomic, strong, readwrite) id<BKRRequestMatching>matcher;
@property (nonatomic, strong, readonly) BKRStubsTestBlock testBlock;
@property (nonatomic, strong, readonly) BKRStubsResponseBlock responseBlock;
@end

@implementation BKRPlayer
@synthesize testBlock = _testBlock;
@synthesize responseBlock = _responseBlock;
@synthesize playheadIndex = _playheadIndex;

- (void)_init {
//    _playingQueue = dispatch_queue_create("com.BKR.playing", DISPATCH_QUEUE_SERIAL);
    _cassetteHandler = [BKRCassetteHandler handler];
    _playheadIndex = 0;
//    _enabled = NO;
}

- (NSArray<BKRPlayableScene *> *)allScenes {
    return (NSArray<BKRPlayableScene *> *)self.cassetteHandler.allScenes;
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

- (void)setCurrentCassette:(BKRPlayableCassette *)currentCassette {
    self.cassetteHandler.currentCassette = currentCassette;
}

- (BKRPlayableCassette *)currentCassette {
    return (BKRPlayableCassette *)self.cassetteHandler.currentCassette;
}

- (void)setEnabled:(BOOL)enabled {
    self.cassetteHandler.enabled = enabled;
    if (enabled) {
        [self _addStubs];
    } else {
        [self _removeStubs];
    }
}

- (BOOL)isEnabled {
    return self.cassetteHandler.isEnabled;
}

//- (void)setEnabled:(BOOL)enabled {
//    dispatch_barrier_sync(self.playingQueue, ^{
//        if (enabled) {
//            [self _addStubs];
//        } else {
//            [self _removeStubs];
//        }
//    });
//    _enabled = enabled;
//}

- (BKRStubsTestBlock)testBlock {
    if (!_testBlock) {
        __strong typeof(self) wself = self;
        _testBlock = ^BOOL(NSURLRequest *request){
            __weak typeof(wself) sself = wself;
            BOOL finalTestResult = [sself.matcher hasMatchForRequest:request withPlayhead:sself.playheadScene inPlayableScenes:sself.allScenes];
            if (!finalTestResult) {
                return finalTestResult;
            }
            NSURLComponents *requestComponents = [NSURLComponents componentsWithString:request.URL.absoluteString];
            if ([sself.matcher respondsToSelector:@selector(hasMatchForRequestScheme:withPlayhead:inPlayableScenes:)]) {
                finalTestResult = [sself.matcher hasMatchForRequestScheme:requestComponents.scheme withPlayhead:sself.playheadScene inPlayableScenes:sself.allScenes];
                if (!finalTestResult) {
                    return finalTestResult;
                }
            }
            if ([sself.matcher respondsToSelector:@selector(hasMatchForRequestHost:withPlayhead:inPlayableScenes:)]) {
                finalTestResult = [sself.matcher hasMatchForRequestHost:requestComponents.host withPlayhead:sself.playheadScene inPlayableScenes:sself.allScenes];
                if (!finalTestResult) {
                    return finalTestResult;
                }
            }
            if ([sself.matcher respondsToSelector:@selector(hasMatchForRequestPath:withPlayhead:inPlayableScenes:)]) {
                finalTestResult = [sself.matcher hasMatchForRequestPath:requestComponents.path withPlayhead:sself.playheadScene inPlayableScenes:sself.allScenes];
                if (!finalTestResult) {
                    return finalTestResult;
                }
            }
            if ([sself.matcher respondsToSelector:@selector(hasMatchForRequestQueryItems:withPlayhead:inPlayableScenes:)]) {
                finalTestResult = [sself.matcher hasMatchForRequestQueryItems:requestComponents.queryItems withPlayhead:sself.playheadScene inPlayableScenes:sself.allScenes];
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
            BKRPlayableScene *matchedScene = [sself.matcher matchForRequest:request withPlayhead:sself.playheadScene inPlayableScenes:sself.allScenes];
            [sself _incrementPlayheadIndex];
            return matchedScene;
        };
    }
    return _responseBlock;
}

- (void)resetPlayhead {
//    __weak typeof(self) wself = self;
//    dispatch_barrier_async(self.cassetteHandler.processingQueue, ^{
//        __strong typeof(wself) sself = wself;
//        sself->_playheadIndex = 0;
//    });
    self.playheadIndex = 0;
}

- (void)setPlayheadIndex:(NSUInteger)playheadIndex {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.cassetteHandler.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        sself->_playheadIndex = playheadIndex;
    });
}

//- (NSArray<BKRPlayableScene *> *)scenes {
//    __block NSArray<BKRPlayableScene *> *playableScenes;
//    dispatch_barrier_sync(self.playingQueue, ^{
//        playableScenes = (NSArray<BKRPlayableScene *> *)self.currentCassette.allScenes;
//    });
//    return playableScenes;
//}

- (void)_addStubs {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.cassetteHandler.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        [BKROHHTTPStubsWrapper stubRequestPassingTest:sself.testBlock withStubResponse:sself.responseBlock];
    });
}

- (void)dealloc {
    [self _removeStubs];
}

- (void)_removeStubs {
    dispatch_barrier_async(self.cassetteHandler.processingQueue, ^{
        [BKROHHTTPStubsWrapper removeAllStubs];
    });
}

- (NSUInteger)playheadIndex {
    __block NSUInteger index;
    __weak typeof(self) wself = self;
    dispatch_sync(self.cassetteHandler.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        index = sself->_playheadIndex;
    });
    return index;
}

// does this need a dispatch barrier?
- (BKRPlayableScene *)playheadScene {
    NSUInteger currentPlayheadIndex = self.playheadIndex;
    if (currentPlayheadIndex >= self.allScenes.count) {
        return nil;
    }
    return [self.allScenes objectAtIndex:currentPlayheadIndex];
}

- (void)_incrementPlayheadIndex {
//    __weak typeof(self) wself = self;
//    dispatch_barrier_async(self.cassetteHandler.processingQueue, ^{
//        __strong typeof(wself) sself = wself;
//        sself->_playheadIndex++;
//    });
    self.playheadIndex++;
}

//- (void)setCurrentCassette:(BKRPlayableCassette *)currentCassette {
//    if (currentCassette) {
//        // This is for debugging purposes
//        NSParameterAssert([currentCassette isKindOfClass:[BKRPlayableCassette class]]);
//    }
//    dispatch_barrier_sync(self.playingQueue, ^{
//        _currentCassette = currentCassette;
//    });
//    [self resetPlayhead];
//}

@end
