//
//  BKRPlayer.m
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import "BKRPlayer.h"
#import "BKRPlayableCassette.h"
#import "BKRPlayingEditor.h"
#import "BKRPlayableRawFrame.h"
#import "BKRPlayableScene.h"
#import "BKROHHTTPStubsWrapper.h"

@interface BKRPlayer ()
@property (nonatomic, strong) BKRPlayingEditor *editor;
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
    _editor = [BKRPlayingEditor editor];
    _playheadIndex = 0;
}

- (NSArray<BKRPlayableScene *> *)allScenes {
    return (NSArray<BKRPlayableScene *> *)self.editor.allScenes;
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
    self.editor.currentCassette = currentCassette;
}

- (BKRPlayableCassette *)currentCassette {
    return (BKRPlayableCassette *)self.editor.currentCassette;
}

- (void)setEnabled:(BOOL)enabled {
    self.editor.enabled = enabled;
    if (enabled) {
        [self _addStubs];
    } else {
        [self _removeStubs];
    }
}

- (BOOL)isEnabled {
    return self.editor.isEnabled;
}

- (BKRStubsTestBlock)testBlock {
    if (!_testBlock) {
        __strong typeof(self) wself = self;
        _testBlock = ^BOOL(NSURLRequest *request){
            __weak typeof(wself) sself = wself;
            NSArray<BKRPlayableScene *> *currentAllScenes = sself.allScenes;
            BKRPlayableScene *currentPlayheadScene = sself.playheadScene;
            BOOL finalTestResult = [sself.matcher hasMatchForRequest:request withPlayhead:currentPlayheadScene inPlayableScenes:currentAllScenes];
            if (!finalTestResult) {
                return finalTestResult;
            }
            NSURLComponents *requestComponents = [NSURLComponents componentsWithString:request.URL.absoluteString];
            if ([sself.matcher respondsToSelector:@selector(hasMatchForRequestScheme:withPlayhead:inPlayableScenes:)]) {
                finalTestResult = [sself.matcher hasMatchForRequestScheme:requestComponents.scheme withPlayhead:currentPlayheadScene inPlayableScenes:currentAllScenes];
                if (!finalTestResult) {
                    return finalTestResult;
                }
            }
            if ([sself.matcher respondsToSelector:@selector(hasMatchForRequestHost:withPlayhead:inPlayableScenes:)]) {
                finalTestResult = [sself.matcher hasMatchForRequestHost:requestComponents.host withPlayhead:currentPlayheadScene inPlayableScenes:currentAllScenes];
                if (!finalTestResult) {
                    return finalTestResult;
                }
            }
            if ([sself.matcher respondsToSelector:@selector(hasMatchForRequestPath:withPlayhead:inPlayableScenes:)]) {
                finalTestResult = [sself.matcher hasMatchForRequestPath:requestComponents.path withPlayhead:currentPlayheadScene inPlayableScenes:currentAllScenes];
                if (!finalTestResult) {
                    return finalTestResult;
                }
            }
            if ([sself.matcher respondsToSelector:@selector(hasMatchForRequestQueryItems:withPlayhead:inPlayableScenes:)]) {
                finalTestResult = [sself.matcher hasMatchForRequestQueryItems:requestComponents.queryItems withPlayhead:currentPlayheadScene inPlayableScenes:currentAllScenes];
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
            BKRPlayableScene *currentPlayhead = sself.playheadScene;
            NSArray<BKRPlayableScene *> *currentAllScenes = sself.allScenes;
            BKRPlayableScene *matchedScene = [sself.matcher matchForRequest:request withPlayhead:currentPlayhead inPlayableScenes:currentAllScenes];
            [sself _incrementPlayheadIndex];
            return matchedScene;
        };
    }
    return _responseBlock;
}

- (void)resetPlayhead {
    self.playheadIndex = 0;
}

- (void)setPlayheadIndex:(NSUInteger)playheadIndex {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.editor.editingQueue, ^{
        __strong typeof(wself) sself = wself;
        sself->_playheadIndex = playheadIndex;
    });
}

- (void)_addStubs {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.editor.editingQueue, ^{
        __strong typeof(wself) sself = wself;
        [BKROHHTTPStubsWrapper stubRequestPassingTest:sself.testBlock withStubResponse:sself.responseBlock];
    });
//    [BKROHHTTPStubsWrapper stubRequestPassingTest:self.testBlock withStubResponse:self.responseBlock];
}

- (void)dealloc {
    [self _removeStubs];
}

- (void)_removeStubs {
    dispatch_barrier_async(self.editor.editingQueue, ^{
        [BKROHHTTPStubsWrapper removeAllStubs];
    });
//    [BKROHHTTPStubsWrapper removeAllStubs];
}

- (NSUInteger)playheadIndex {
    __block NSUInteger index;
    __weak typeof(self) wself = self;
    dispatch_sync(self.editor.editingQueue, ^{
        __strong typeof(wself) sself = wself;
        index = sself->_playheadIndex;
    });
    return index;
}

// does this need a dispatch barrier?
// has one in the getters and setters, right?
- (BKRPlayableScene *)playheadScene {
    NSUInteger currentPlayheadIndex = self.playheadIndex;
    if (currentPlayheadIndex >= self.allScenes.count) {
        return nil;
    }
    return [self.allScenes objectAtIndex:currentPlayheadIndex];
}

- (void)_incrementPlayheadIndex {
    self.playheadIndex++;
}

@end
