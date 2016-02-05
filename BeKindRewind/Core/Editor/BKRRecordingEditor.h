//
//  BKRRecordingEditor.h
//  Pods
//
//  Created by Jordan Zucker on 1/29/16.
//
//

#import "BKREditor.h"
#import "BKRRecorder.h" // can remove this eventually, only need the block declaration

@class BKRRecordableRawFrame;
@interface BKRRecordingEditor : BKREditor

@property (nonatomic, strong) NSDate *recordingStartTime;

- (void)updateRecordingStartTime;

- (void)addFrame:(BKRRecordableRawFrame *)frame;

- (void)executeEndRecordingBlock:(BKREndRecordingTaskBlock)endRecordingBlock withTask:(NSURLSessionTask *)task;

@end
