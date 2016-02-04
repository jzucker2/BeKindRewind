//
//  BKRPlayingEditor.h
//  Pods
//
//  Created by Jordan Zucker on 1/29/16.
//
//

#import "BKREditor.h"
#import "BKRRequestMatching.h"
#import "BKRPlayer.h"

@class BKRPlayer;

@interface BKRPlayingEditor : BKREditor

- (void)addStubsForMatcher:(id<BKRRequestMatching>)matcher beforeStubsBlock:(BKRBeforeAddingStubs)beforeStubsBlock afterStubsBlock:(BKRAfterAddingStubs)afterStubsBlock;


@end
