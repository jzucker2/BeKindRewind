//
//  BKRRecordableRawFrame.h
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import "BKRRawFrame.h"

@interface BKRRecordableRawFrame : BKRRawFrame

// returns specialized, serializable version for saving or restoring
- (BKRFrame *)editedFrame;

@end
