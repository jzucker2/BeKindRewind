//
//  BKRPlayingEditor.h
//  Pods
//
//  Created by Jordan Zucker on 1/29/16.
//
//

#import "BKREditor.h"
#import "BKRRequestMatching.h"

@interface BKRPlayingEditor : BKREditor

- (void)addStubsForMatcher:(id<BKRRequestMatching>)matcher;


@end
