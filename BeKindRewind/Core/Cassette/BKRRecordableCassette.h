//
//  BKRRecordableCassette.h
//  Pods
//
//  Created by Jordan Zucker on 1/20/16.
//
//

#import "BKRCassette.h"
#import "BKRPlistSerializing.h"

@class BKRRawFrame;
@interface BKRRecordableCassette : BKRCassette <BKRPlistSerializing>

@property (nonatomic, getter=isRecording) BOOL recording;

- (void)addFrame:(BKRRawFrame *)frame;

@end
