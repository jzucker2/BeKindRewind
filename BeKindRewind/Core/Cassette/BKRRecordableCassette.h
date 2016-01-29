//
//  BKRRecordableCassette.h
//  Pods
//
//  Created by Jordan Zucker on 1/20/16.
//
//

#import "BKRCassette.h"
#import "BKRPlistSerializing.h"

@class BKRRecordableRawFrame;
@interface BKRRecordableCassette : BKRCassette <BKRPlistSerializer>

- (void)addFrame:(BKRRecordableRawFrame *)frame;

@end
