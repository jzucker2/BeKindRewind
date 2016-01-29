//
//  BKRPlayer.h
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

//#import "BKRCassetteHandler.h"
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
//- (void)setCassette:(BKRPlayableCassette *)cassette;

@property (nonatomic, strong, readonly) id<BKRRequestMatching>matcher;

- (BKRPlayableScene *)playheadScene;

- (void)resetPlayhead;
- (NSArray<BKRPlayableScene *> *)allScenes;

@end
