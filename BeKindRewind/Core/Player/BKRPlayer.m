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

- (NSArray<BKRScene *> *)allScenes {
    return self.editor.allScenes;
}

- (instancetype)initWithMatcherClass:(Class<BKRRequestMatching>)matcherClass {
    NSParameterAssert(matcherClass);
    self = [super init];
    if (self) {
        _matcher = [matcherClass matcher];
        _editor = [BKRPlayingEditor editorWithMatcher:_matcher];
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
    [self setEnabled:enabled withCompletionHandler:nil];
}

- (void)setEnabled:(BOOL)enabled withCompletionHandler:(void (^)(void))completionBlock {
//    [self.editor setEnabled:enabled withCompletionHandler:completionBlock];
    [self.editor setEnabled:enabled withCompletionHandler:^(BOOL updatedEnabled, BKRCassette *cassette) {
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }
    }];
}

- (BOOL)isEnabled {
    return self.editor.isEnabled;
}

- (void)resetWithCompletionBlock:(void (^)(void))completionBlock {
    self.currentCassette = nil;
    [self.editor setEnabled:NO withCompletionHandler:^(BOOL updatedEnabled, BKRCassette *cassette) {
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }
    }];
}

@end
