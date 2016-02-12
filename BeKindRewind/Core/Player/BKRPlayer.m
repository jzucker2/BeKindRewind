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
#import "BKRScene+Playable.h"

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

- (NSArray<BKRScene *> *)allScenes {
    return self.editor.allScenes;
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
    if (currentCassette) {
        [self _addStubs];
    } else {
        [self.editor removeAllStubs];
    }
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

- (void)_addStubs {
    [self.editor addStubsForMatcher:self.matcher];
}

- (void)reset {
    self.currentCassette = nil;
    self.enabled = NO;
    self.beforeAddingStubsBlock = nil;
    self.afterAddingStubsBlock = nil;
}

#pragma mark - BKRVCRPlaying

- (void)setAfterAddingStubsBlock:(BKRAfterAddingStubs)afterAddingStubsBlock {
    self.editor.afterAddingStubsBlock = afterAddingStubsBlock;
}

- (BKRAfterAddingStubs)afterAddingStubsBlock {
    return self.editor.afterAddingStubsBlock;
}

- (void)setBeforeAddingStubsBlock:(BKRBeforeAddingStubs)beforeAddingStubsBlock {
    self.editor.beforeAddingStubsBlock = beforeAddingStubsBlock;
}

- (BKRBeforeAddingStubs)beforeAddingStubsBlock {
    return self.editor.beforeAddingStubsBlock;
}

@end
