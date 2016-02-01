//
//  BKRPlayer.h
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import "BKRRequestMatching.h"

@class BKRPlayableCassette;
@class BKRPlayableScene;

@protocol BKRPlayerDelegate;

@interface BKRPlayer : NSObject

- (instancetype)initWithMatcherClass:(Class<BKRRequestMatching>)matcherClass;
+ (instancetype)playerWithMatcherClass:(Class<BKRRequestMatching>)matcherClass;

/**
 *  Whether or not network activity should be recorded
 */
@property (nonatomic, getter=isEnabled) BOOL enabled;

@property (nonatomic, strong) BKRPlayableCassette *currentCassette;

@property (nonatomic, strong, readonly) id<BKRRequestMatching>matcher;

@property (nonatomic, weak) id<BKRPlayerDelegate> delegate;

- (BKRPlayableScene *)playheadScene;

- (void)resetPlayhead;
- (NSArray<BKRPlayableScene *> *)allScenes;

@end

@protocol BKRPlayerDelegate <NSObject>

- (void)unmatchedRequest:(NSURLRequest *)request;

@end
