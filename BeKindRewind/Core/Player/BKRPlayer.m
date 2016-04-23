//
//  BKRPlayer.m
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import "BKRConfiguration.h"
#import "BKRPlayer.h"
#import "BKRCassette+Playable.h"
#import "BKRPlayingEditor.h"
#import "BKRScene+Playable.h"

@interface BKRPlayer ()
@property (nonatomic, strong) BKRPlayingEditor *editor;
@end

@implementation BKRPlayer

- (NSArray<BKRScene *> *)allScenes {
    return self.editor.allScenes;
}

//- (instancetype)initWithMatcherClass:(Class<BKRRequestMatching>)matcherClass {
//    NSParameterAssert(matcherClass);
//    self = [super init];
//    if (self) {
//        _editor = [BKRPlayingEditor editorWithMatcher:_matcher];
//        NSAssert(_matcher, @"There must be a matcher for the player to function properly");
//        _editor = [BKRPlayingEditor editorWithMatcher:_matcher];
//    }
//    return self;
//}

//+ (instancetype)playerWithMatcherClass:(Class<BKRRequestMatching>)matcherClass {
//    return [[self alloc] initWithMatcherClass:matcherClass];
//}

- (instancetype)initWithMatcherClass:(Class<BKRRequestMatching>)matcherClass {
    BKRConfiguration *configuration = [BKRConfiguration configurationWithMatcherClass:matcherClass];
    return [self initWithConfiguration:configuration];
}

+ (instancetype)playerWithMatcherClass:(Class<BKRRequestMatching>)matcherClass {
    return [[self alloc] initWithMatcherClass:matcherClass];
}

- (instancetype)initWithConfiguration:(BKRConfiguration *)configuration {
    self = [super init];
    if (self) {
        _editor = [BKRPlayingEditor editorWithConfiguration:configuration];
    }
    return self;
}

+ (instancetype)playerWithConfiguration:(BKRConfiguration *)configuration {
    return [[self alloc] initWithConfiguration:configuration];
}

- (id<BKRRequestMatching>)matcher {
    return self.editor.matcher;
}

- (void)setCurrentCassette:(BKRCassette *)currentCassette {
    self.editor.currentCassette = currentCassette;
}

- (BKRCassette *)currentCassette {
    return self.editor.currentCassette;
}

- (void)setEnabled:(BOOL)enabled {
    [self setEnabled:enabled withCompletionHandler:nil];
}

- (void)setEnabled:(BOOL)enabled withCompletionHandler:(void (^)(void))completionBlock {
    [self.editor setEnabled:enabled withCompletionHandler:^(BOOL updatedEnabled, BKRCassette *cassette) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (BOOL)isEnabled {
    return self.editor.isEnabled;
}

- (void)resetWithCompletionBlock:(void (^)(void))completionBlock {
    [self.editor resetWithCompletionBlock:^{
        if (completionBlock) {
            completionBlock();
        }
    }];
}

@end
