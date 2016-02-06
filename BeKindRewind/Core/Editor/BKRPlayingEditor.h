//
//  BKRPlayingEditor.h
//  Pods
//
//  Created by Jordan Zucker on 1/29/16.
//
//

#import "BKREditor.h"
#import "BKRRequestMatching.h"
#import "BKRConstants.h"

@class BKRPlayer;

/**
 *  This subclass is for turning cassettes into stubs in a thread-safe manner
 */
@interface BKRPlayingEditor : BKREditor

/**
 *  Adds stubs using matcher conforming to @protocol BKRRequestMatching with
 *  a block to execute on the main queue after all stubs are added.
 *
 *  @param matcher         object used to construct stubs for playback, contains rules for stubbing
 *  @param afterStubsBlock block to execute on main queue after all stubs are added
 */
- (void)addStubsForMatcher:(id<BKRRequestMatching>)matcher afterStubsBlock:(BKRAfterAddingStubs)afterStubsBlock;


@end
