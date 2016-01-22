//
//  BKRRawFrame.h
//  Pods
//
//  Created by Jordan Zucker on 1/20/16.
//
//

#import "BKRFrame.h"

@interface BKRRawFrame : BKRFrame

@property (nonatomic, copy) id item;

// returns serializable version for saving or restoring
- (BKRFrame *)editedFrame;

@end
