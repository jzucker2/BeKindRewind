//
//  BKRRecordingEditor.h
//  Pods
//
//  Created by Jordan Zucker on 1/29/16.
//
//

#import "BKRConstants.h"
#import "BKREditor.h"
#import "BKRPlistSerializing.h"
#import "BKRVCRActions.h"

@class BKRRawFrame;

/**
 *  This subclass is for turning network request components into cassettes in a thread-safe manner.
 *
 *  @since 1.0.0
 */
@interface BKRRecordingEditor : BKREditor <BKRPlistSerializer, BKRVCRRecording>

/**
 *  Timestamp at which current recording session begins
 *
 *  @since 1.0.0
 */
@property (nonatomic, strong) NSNumber *recordingStartTime;

/**
 *  This is read-only and set by the receiver if anything is actually recorded during the session.
 *
 *  @since 1.0.0
 */
@property (nonatomic, assign, readonly) BOOL handledRecording;

/**
 *  This is the main method used to add information about a task component to a
 *  cassette in a thread-safe, non-blocking manner
 *
 *  @param item    this is the component of the network event
 *                 (NSURLRequest, NSURLResponse, NSData, NSError, etc.)
 *  @param task    this is the task for which to organize network event components around
 *  @param context this is the context of where this method is called from. Passed in to
 *                 provide additional information for recording tasks properly
 *
 *  @since 1.0.0
 */
- (void)addItem:(id)item forTask:(NSURLSessionTask *)task withContext:(BKRRecordingContext)context;

/**
 *  This is called on the receiver's custom queue
 *
 *  @param task this is supplied to the beginRecordingBlock executed on the receiver's custom queue
 *
 *  @since 1.0.0
 */
- (void)executeBeginRecordingBlockWithTask:(NSURLSessionTask *)task;

/**
 *  Execute end of recording block on the main queue
 *
 *  @param endRecordingBlock block to execute at the end of a network request recording
 *  @param task              task that was being recorded
 *
 *  @since 1.0.0
 */
- (void)executeEndRecordingBlockWithTask:(NSURLSessionTask *)task;

@end
