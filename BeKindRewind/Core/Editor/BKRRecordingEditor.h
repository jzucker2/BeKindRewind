//
//  BKRRecordingEditor.h
//  Pods
//
//  Created by Jordan Zucker on 1/29/16.
//
//

#import "BKREditor.h"

@class BKRRecordableRawFrame;
@interface BKRRecordingEditor : BKREditor

@property (nonatomic, strong) NSDate *recordingStartTime;

- (void)updateRecordingStartTime;

- (void)addFrame:(BKRRecordableRawFrame *)frame;

@end
