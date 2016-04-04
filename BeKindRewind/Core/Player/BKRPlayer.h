//
//  BKRPlayer.h
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import "BKRRequestMatching.h"
#import "BKRConstants.h"

@class BKRCassette;
@class BKRScene;

/**
 *  This class manages playing back stubs for network requests at
 *  a high level.
 *
 *  @since 1.0.0
 */
@interface BKRPlayer : NSObject

/**
 *  Designated initializer for BKRPlayer
 *
 *  @param matcherClass class of object used to set the stubbing rules
 *
 *  @return instance of BKRPlayer stubs assembled using provided matcher class
 *
 *  @since 1.0.0
 */
- (instancetype)initWithMatcherClass:(Class<BKRRequestMatching>)matcherClass;

/**
 *  Convenience initializer for BKRPlayer
 *
 *  @param matcherClass class of object used to set stubbing rules
 *
 *  @return instance of BKRPlayer stubs assembled using provided matcher class
 *
 *  @since 1.0.0
 */
+ (instancetype)playerWithMatcherClass:(Class<BKRRequestMatching>)matcherClass;

/**
 *  Whether or not network activity should be recorded
 *
 *  @since 1.0.0
 */
@property (nonatomic, getter=isEnabled) BOOL enabled;

/**
 *  Thread-safe method that updates the enabled state on the receiver's queue
 *
 *  @param enabled         whether or not to receiver should be enabled
 *  @param completionBlock block runs on receiver's queue after enabled is updated
 *
 *  @since 1.0.0
 */
- (void)setEnabled:(BOOL)enabled withCompletionHandler:(void (^)(void))completionBlock;

/**
 *  Current cassette used as a source for stubs. If this is nil,
 *  then no recordings are loaded as stubs for playback.
 *
 *  @since 1.0.0
 */
@property (nonatomic, strong) BKRCassette *currentCassette;

/**
 *  Instance of matcher class created from class parameter used 
 *  in initializer
 *
 *  @since 1.0.0
 */
@property (nonatomic, strong, readonly) id<BKRRequestMatching>matcher;

/**
 *  Reset the player's enabled state along with before 
 *  and after playback blocks. If the matcher saves any state,
 *  that can be reset here by implemented the optional `reset` method
 *  in the BKRRequestMatching protocol
 *
 *  @since 1.0.0
 */
- (void)resetWithCompletionBlock:(void (^)(void))completionBlock;

/**
 *  Ordered array of BKRPlayableScene objects from current cassette
 *
 *  @return ordered array by creation date of each scene or nil if no current cassette
 *
 *  @since 1.0.0
 */
- (NSArray<BKRScene *> *)allScenes;

@end
