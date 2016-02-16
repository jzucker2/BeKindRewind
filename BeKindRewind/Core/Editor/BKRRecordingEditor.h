//
//  BKRRecordingEditor.h
//  Pods
//
//  Created by Jordan Zucker on 1/29/16.
//
//

#import "BKREditor.h"
#import "BKRPlistSerializing.h"
#import "BKRVCRActions.h"

@class BKRRawFrame;

/**
 *  This subclass is for turning network request components into cassettes in a thread-safe manner.
 */
@interface BKRRecordingEditor : BKREditor <BKRPlistSerializer, BKRVCRRecording>

/**
 *  Date at which current recording session begins
 */
@property (nonatomic, strong) NSDate *recordingStartTime;

@property (nonatomic, assign, readonly) BOOL handledRecording;

- (void)reset;

/**
 *  Update the recordingStartTime to now or set it to nil if BKRRecordingEditor is not enabled
 */
//- (void)updateRecordingStartTimeWithEnabled:(BOOL)desiredEnabled;

/**
 *  Add raw recordable frame representing a component of a network request to the current cassette
 *
 *  @param frame component of a network request
 */
- (void)addFrame:(BKRRawFrame *)frame;

- (void)executeBeginRecordingBlockWithTask:(NSURLSessionTask *)task;

/**
 *  Execute end of recording block on the main queue
 *
 *  @param endRecordingBlock block to execute at the end of a network request recording
 *  @param task              task that was being recorded
 */
- (void)executeEndRecordingBlockWithTask:(NSURLSessionTask *)task;

//- (void)resetHandledRecording;

@end
