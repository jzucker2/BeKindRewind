//
//  BKRPlayableCassette.h
//  Pods
//
//  Created by Jordan Zucker on 1/21/16.
//
//

#import "BKRCassette.h"
#import "BKRPlistSerializing.h"
#import "BKRConstants.h"

/**
 *  Subclass is used for managing BKRPlayableScene objects
 */
@interface BKRPlayableCassette : BKRCassette <BKRPlistDeserializer>

/**
 *  This executes on the main queue after adding all stubs to the BKRPlayer
 *
 *  @param afterStubsBlock block to execute after all stubs added
 */
- (void)executeAfterAddingStubsBlock:(BKRAfterAddingStubs)afterStubsBlock;

@end
