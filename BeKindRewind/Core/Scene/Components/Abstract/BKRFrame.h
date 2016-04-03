//
//  BKRFrame.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRPlistSerializing.h"

/**
 *  This abstract class represents a single component of a network call. Many frames make up a scene, 
 *  just like in a video. Examples of components that can be frames are requests, responses, data 
 *  received, and any possible errors. Each component as it is received is recorded as a separate frame.
 *
 *  @since 1.0.0
 */
@interface BKRFrame : NSObject <BKRPlistSerializing>

/**
 *  Initialize a frame from a NSURLSessionTask
 *
 *  @param task network request task to create a frame with
 *
 *  @return newly initialized instance of a frame class
 *
 *  @since 1.0.0
 */
- (instancetype)initWithTask:(NSURLSessionTask *)task;

/**
 *  Convenience initializer for a frame from a NSURLSessionTask
 *
 *  @param task network request task to create a frame with
 *
 *  @return newly initialized instance of a frame class
 *
 *  @since 1.0.0
 */
+ (instancetype)frameWithTask:(NSURLSessionTask *)task;

/**
 *  Initialize a frame from another frame instance
 *
 *  @param frame existing frame to incorporate data from during initialization
 *
 *  @return newly initialized instance of a frame class
 *
 *  @since 1.0.0
 */
- (instancetype)initFromFrame:(BKRFrame *)frame;

/**
 *  Convenience initializer for a frame from another frame instance
 *
 *  @param frame existing frame to incorporate data from during initialization
 *
 *  @return newly initialized instance of a frame class
 *
 *  @since 1.0.0
 */
+ (instancetype)frameFromFrame:(BKRFrame *)frame;

/**
 *  Initialize a frame from a unique identifier. This unique identifier is expected
 *  to be associated with a unique identifier added to a network request by BeKindRewind
 *
 *  @param identifier unique identifier intended to be associated with a network request
 *
 *  @return newly initialized instance of a frame class
 *
 *  @since 1.0.0
 */
- (instancetype)initWithIdentifier:(NSString *)identifier;

/**
 *  Convenience initializer for a frame from a unique identifier. This unique identifier is expected
 *  to be associated with a unique identifier added to a network request by BeKindRewind
 *
 *  @param identifier unique identifier intended to be associated with a network request
 *
 *  @return newly initialized instance of a frame class
 *
 *  @since 1.0.0
 */
+ (instancetype)frameWithIdentifier:(NSString *)identifier;

/**
 *  Unique identifier used to group information associated with this information about a network request
 *
 *  @since 1.0.0
 */
@property (nonatomic, copy, readonly) NSString *uniqueIdentifier;

/**
 *  Timestamp when this frame was created, useful for timing and playback control
 *
 *  @since 1.0.0
 */
@property (nonatomic, strong, readonly) NSNumber *creationDate;

@end
