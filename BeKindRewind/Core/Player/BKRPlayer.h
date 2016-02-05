//
//  BKRPlayer.h
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import "BKRRequestMatching.h"
#import "BKRConstants.h"

@class BKRPlayableCassette;
@class BKRPlayableScene;

@interface BKRPlayer : NSObject

- (instancetype)initWithMatcherClass:(Class<BKRRequestMatching>)matcherClass;
+ (instancetype)playerWithMatcherClass:(Class<BKRRequestMatching>)matcherClass;

/**
 *  Whether or not network activity should be recorded
 */
@property (nonatomic, getter=isEnabled) BOOL enabled;

@property (nonatomic, strong) BKRPlayableCassette *currentCassette;

@property (nonatomic, strong, readonly) id<BKRRequestMatching>matcher;

- (void)reset;

- (NSArray<BKRPlayableScene *> *)allScenes;

@property (nonatomic, copy) BKRBeforeAddingStubs beforeAddingStubsBlock; // executed on main thread
@property (nonatomic, copy) BKRAfterAddingStubs afterAddingStubsBlock; // executed on main thread

@end
