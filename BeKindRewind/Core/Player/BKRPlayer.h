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

// typedef returnType (^TypeName)(parameterTypes);
typedef void (^BKRBeforeAddingStubs)(void);
typedef void (^BKRAfterAddingStubs)(void);

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

@property (nonatomic, copy) BKRBeforeAddingStubs beforeAddingStubsBlock;
@property (nonatomic, copy) BKRAfterAddingStubs afterAddingStubsBlock;

@end
