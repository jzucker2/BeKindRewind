//
//  NSObject+BKRVCRAdditions.h
//  Pods
//
//  Created by Jordan Zucker on 2/19/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRVCRActions.h"

/**
 *  These are extra methods used by the BeKindRewind framework
 *
 *  @since 1.0.0
 */
@interface NSObject (BKRVCRAdditions)

/**
 *  This is a wrapper method that ensures a block executes on the main queue. It
 *  first checks if the current thread is the main thread before trying to schedule
 *  the block for asynchronous execution on the main queue
 *
 *  @param finalResult           the success of the operation to pass into the block
 *                               as a parameter
 *  @param cassetteHandlingBlock the block to execute on the main queue
 *
 *  @since 1.0.0
 */
- (void)BKR_executeCassetteHandlingBlockWithFinalResult:(BOOL)finalResult onMainQueue:(BKRCassetteHandlingBlock)cassetteHandlingBlock;

@end
