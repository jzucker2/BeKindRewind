//
//  BKRScene+Recordable.h
//  Pods
//
//  Created by Jordan Zucker on 2/12/16.
//
//

#import "BKRScene.h"
#import "BKRConstants.h"
#import "BKRPlistSerializing.h"

@class BKRRawFrame;

/**
 *  This category handles all of the data associated with a single,
 *  specific NSURLSessionTask, with each portion represented
 *  by a single BKRFrame
 *
 *  @since 1.0.0
 */
@interface BKRScene (Recordable) <BKRPlistSerializer>

/**
 *  Designated initializer for a recordable scene created from
 *  a single piece of a network request
 *
 *  @param frame   component of a network request
 *  @param context helps determine the type of frame subclass to store item as
 *
 *  @return instance of a recordable scene
 *
 *  @since 1.0.0
 */
- (instancetype)initFromFrame:(BKRRawFrame *)frame withContext:(BKRRecordingContext)context;

/**
 *  Convenience initializer for a recordable scene created from
 *  a single piece of a network request
 *
 *  @param frame   component of a network request
 *  @param context helps determine the type of frame subclass to store item as
 *
 *  @return instance of a recordable scene
 *
 *  @since 1.0.0
 */
+ (instancetype)sceneFromFrame:(BKRRawFrame *)frame withContext:(BKRRecordingContext)context;

/**
 *  Add component of a network request as a frame
 *
 *  @param frame   component of network request
 *  @param context helps determine the type of frame subclass to store item as
 *
 *  @since 1.0.0
 */
- (void)addFrame:(BKRRawFrame *)frame withContext:(BKRRecordingContext)context;

@end
