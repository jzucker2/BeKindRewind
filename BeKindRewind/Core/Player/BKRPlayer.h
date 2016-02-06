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

/**
 *  This class manages playing back stubs for network requests at
 *  a high level.
 */
@interface BKRPlayer : NSObject

/**
 *  Designated initializer for BKRPlayer
 *
 *  @param matcherClass class of object used to set the stubbing rules
 *
 *  @return instance of BKRPlayer stubs assembled using provided matcher class
 */
- (instancetype)initWithMatcherClass:(Class<BKRRequestMatching>)matcherClass;

/**
 *  Convenience initializer for BKRPlayer
 *
 *  @param matcherClass class of object used to set stubbing rules
 *
 *  @return instance of BKRPlayer stubs assembled using provided matcher class
 */
+ (instancetype)playerWithMatcherClass:(Class<BKRRequestMatching>)matcherClass;

/**
 *  Whether or not network activity should be recorded
 */
@property (nonatomic, getter=isEnabled) BOOL enabled;

/**
 *  Current cassette used as a source for stubs. If this is nil,
 *  then no recordings are loaded as stubs for playback.
 */
@property (nonatomic, strong) BKRPlayableCassette *currentCassette;

/**
 *  Instance of matcher class created from class parameter used 
 *  in initializer
 */
@property (nonatomic, strong, readonly) id<BKRRequestMatching>matcher;

/**
 *  Reset the player's enabled state along with before 
 *  and after playback blocks
 */
- (void)reset;

/**
 *  Ordered array of BKRPlayableScene objects from current cassette
 *
 *  @return ordered array by creation date of each scene or nil if no current cassette
 */
- (NSArray<BKRPlayableScene *> *)allScenes;

/**
 *  Block is executed on the main thread before all stubs for a
 *  playback session are added
 *  @note make sure not to deadlock or execute slow code in this block
 */
@property (nonatomic, copy) BKRBeforeAddingStubs beforeAddingStubsBlock;

/**
 *  Block is executed on the main thread after all stubs for a
 *  playback session are added
 *  @note make sure not to deadlock or execute slow code in this block
 */
@property (nonatomic, copy) BKRAfterAddingStubs afterAddingStubsBlock; // executed on main thread

@end
