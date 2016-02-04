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
#import "BKROHHTTPStubsWrapper.h"

@interface BKRPlayer ()
@property (nonatomic, strong) BKRPlayingEditor *editor;
@property (nonatomic, strong, readwrite) id<BKRRequestMatching>matcher;
@end

@implementation BKRPlayer

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

- (void)_addStubs {
    [self.editor addStubsForMatcher:self.matcher];
}

@end
