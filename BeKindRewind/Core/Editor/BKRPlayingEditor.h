//
//  BKRPlayingEditor.h
//  Pods
//
//  Created by Jordan Zucker on 1/29/16.
//
//

#import "BKREditor.h"
#import "BKRRequestMatching.h"
#import "BKRPlayer.h" // can remove this eventually, only need the block declaration

@class BKRPlayer;

@interface BKRPlayingEditor : BKREditor

- (void)addStubsForMatcher:(id<BKRRequestMatching>)matcher beforeStubsBlock:(BKRBeforeAddingStubs)beforeStubsBlock afterStubsBlock:(BKRAfterAddingStubs)afterStubsBlock;


@end
