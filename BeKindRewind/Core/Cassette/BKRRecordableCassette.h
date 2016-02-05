//
//  BKRRecordableCassette.h
//  Pods
//
//  Created by Jordan Zucker on 1/20/16.
//
//

#import "BKRCassette.h"
#import "BKRPlistSerializing.h"
#import "BKRConstants.h"

@class BKRRecordableRawFrame;
@interface BKRRecordableCassette : BKRCassette <BKRPlistSerializer>

- (void)addFrame:(BKRRecordableRawFrame *)frame;

- (void)executeEndTaskRecordingBlock:(BKREndRecordingTaskBlock)endTaskBlock withTask:(NSURLSessionTask *)task;


@end
