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

@interface BKRPlayer : NSObject

- (instancetype)initWithMatcherClass:(Class<BKRRequestMatching>)matcherClass;
+ (instancetype)playerWithMatcherClass:(Class<BKRRequestMatching>)matcherClass;

/**
 *  Whether or not network activity should be recorded
 */
@property (nonatomic, getter=isEnabled) BOOL enabled;

@property (nonatomic, strong) BKRPlayableCassette *currentCassette;

@property (nonatomic, strong, readonly) id<BKRRequestMatching>matcher;

- (NSArray<BKRPlayableScene *> *)allScenes;

@end
