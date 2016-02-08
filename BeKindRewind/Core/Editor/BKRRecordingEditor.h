//
//  BKRRecordingEditor.h
//  Pods
//
//  Created by Jordan Zucker on 1/29/16.
//
//

#import "BKREditor.h"
#import "BKRConstants.h"

@class BKRRecordableRawFrame;

/**
 *  This subclass is for turning network request components into cassettes in a thread-safe manner.
 */
@interface BKRRecordingEditor : BKREditor

/**
 *  Date at which current recording session begins
 */
@property (nonatomic, strong) NSDate *recordingStartTime;

@property (nonatomic, assign, readonly) BOOL handledRecording;

/**
 *  Update the recordingStartTime to now or set it to nil if BKRRecordingEditor is not enabled
 */
- (void)updateRecordingStartTime;

/**
 *  Add raw recordable frame representing a component of a network request to the current cassette
 *
 *  @param frame component of a network request
 */
- (void)addFrame:(BKRRecordableRawFrame *)frame;

/**
 *  Execute end of recording block on the main queue
 *
 *  @param endRecordingBlock block to execute at the end of a network request recording
 *  @param task              task that was being recorded
 */
- (void)executeEndRecordingBlock:(BKREndRecordingTaskBlock)endRecordingBlock withTask:(NSURLSessionTask *)task;

@end
