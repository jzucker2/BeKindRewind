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
#import "BKRPlayableScene.h"

@interface BKRPlayer ()
@property (nonatomic, strong) BKRPlayingEditor *editor;
@property (nonatomic, strong, readwrite) id<BKRRequestMatching>matcher;
@end

@implementation BKRPlayer
@synthesize beforeAddingStubsBlock = _beforeAddingStubsBlock;
@synthesize afterAddingStubsBlock = _afterAddingStubsBlock;

- (void)_init {
    _editor = [BKRPlayingEditor editor];
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
    [self _addStubs];
}

- (BKRPlayableCassette *)currentCassette {
    return (BKRPlayableCassette *)self.editor.currentCassette;
}

- (void)setEnabled:(BOOL)enabled {
    self.editor.enabled = enabled;
}

- (BOOL)isEnabled {
    return self.editor.isEnabled;
}

// TODO: probably should add before stubs on the editor's queue
- (void)_addStubs {
    // make sure this executes on the main thread
    if (self.beforeAddingStubsBlock) {
        if ([NSThread isMainThread]) {
            self.beforeAddingStubsBlock();
        } else {
            // if player is called from a background queue, make sure this happens on main queue
            __weak typeof(self) wself = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(wself) sself = wself;
                sself.beforeAddingStubsBlock();
            });
        }
    }
    [self.editor addStubsForMatcher:self.matcher afterStubsBlock:self.afterAddingStubsBlock];
}

- (void)reset {
    self.currentCassette = nil;
    self.enabled = NO;
    self.beforeAddingStubsBlock = nil;
    self.afterAddingStubsBlock = nil;
}

@end
