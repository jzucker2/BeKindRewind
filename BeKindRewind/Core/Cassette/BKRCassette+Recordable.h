//
//  BKRCassette+Recordable.h
//  Pods
//
//  Created by Jordan Zucker on 2/15/16.
//
//

#import "BKRCassette.h"
#import "BKRPlistSerializing.h"
#import "BKRConstants.h"

@class BKRRawFrame;

/**
 *  This category is for recordable-related functionality for a BKRCassette instance
 */
@interface BKRCassette (Recordable) <BKRPlistSerializer>

/**
 *  Add pieces of network requests to this cassette. Cassette will combine
 *  these "frames" into full scenes.
 *
 *  @param frame piece of a network request that needs to be grouped into a BRKScene
 */
- (void)addFrame:(BKRRawFrame *)frame;

/**
 *  This executes on the main queue after adding all frames for a particular scene/network
 *  task to a cassette for grouping into scenes.
 *
 *  @param endTaskBlock block to execute after all frames are added for a NSURLSessionTask. This will execute after every single network request if it is not nil.
 *  @param task         NSURLSessionTask that just finished recording
 */
- (void)executeEndTaskRecordingBlock:(BKREndRecordingTaskBlock)endTaskBlock withTask:(NSURLSessionTask *)task;

@end
