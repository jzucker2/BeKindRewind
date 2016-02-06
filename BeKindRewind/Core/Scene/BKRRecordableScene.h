//
//  BKRRecordableScene.h
//  Pods
//
//  Created by Jordan Zucker on 1/21/16.
//
//

#import "BKRPlistSerializing.h"
#import "BKRScene.h"

@class BKRRecordableRawFrame;

/**
 *  This contains all of the data associated with a single,
 *  specific NSURLSessionTask, with each portion represented
 *  by a single BKRFrame
 */
@interface BKRRecordableScene : BKRScene <BKRPlistSerializer>

/**
 *  Designated initializer for a recordable scene created from
 *  a single piece of a network request
 *
 *  @param frame component of a network request
 *
 *  @return instance of a recordable scene
 */
- (instancetype)initFromFrame:(BKRRecordableRawFrame *)frame;

/**
 *  Convenience initializer for a recordable scene created from
 *  a single piece of a network request
 *
 *  @param frame component of a network request
 *
 *  @return instance of a recordable scene
 */
+ (instancetype)sceneFromFrame:(BKRRecordableRawFrame *)frame;

/**
 *  Add component of a network request as a frame
 *
 *  @param frame component of network request
 */
- (void)addFrame:(BKRRecordableRawFrame *)frame;

@end
