//
//  BKRRecorder.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRConstants.h"

@class BKRRecordableCassette;
@class BKRRecordableScene;

/**
 *  This object is responsible for collecting and storing all information associated
 *  with a network request.
 */
@interface BKRRecorder : NSObject

/**
 *  Whether or not network activity should be recorded
 */
@property (nonatomic, getter=isEnabled) BOOL enabled;

@property (nonatomic, assign, readonly) BOOL didRecord;

/**
 *  Current cassette used to store network requests. If this is nil,
 *  then no recordings are stored.
 */
@property (nonatomic, strong) BKRRecordableCassette *currentCassette;

/**
 *  This block executes on the main queue before any network request
 *  begins. Make sure not to deadlock or execute slow code. It passes in
 *  the NSURLSessionTask associated with this recording.
 *
 *  @note this block is executed synchronously on the main queue
 */
@property (nonatomic, copy) BKRBeginRecordingTaskBlock beginRecordingBlock;

/**
 *  This block executes on the main queue after any network request
 *  begins. Make sure not to deadlock or execute slow code. It passes in
 *  the NSURLSessionTask associated with this recording.
 *
 *  @note this block is executed asynchronously on the main queue
 */
@property (nonatomic, copy) BKREndRecordingTaskBlock endRecordingBlock;

/**
 *  Ordered array of BKRRecordableScene objects from current cassette
 *
 *  @return ordered array by creation date of each scene or nil if no current cassette
 */
- (NSArray<BKRRecordableScene *> *)allScenes;

/**
 *  Singleton instance is used because we cannot pass in a
 *  reference to every networking class
 *
 *  @return singleton recorder instance
 */
+ (instancetype)sharedInstance;

/**
 *  Reset all recorded values and before and after recording
 *  task blocks
 */
- (void)reset;

/**
 *  Called by networking swizzled classes to begin recording
 *  for a task by executing the beginRecordingBlock
 *
 *  @param task NSURLSessionTask that just began executing
 */
- (void)beginRecording:(NSURLSessionTask *)task;

/**
 *  Called by networking swizzled classes to set the original request
 *
 *  @param task NSURLSessionTask that just began executing
 */
- (void)initTask:(NSURLSessionTask *)task;

/**
 *  Called by networking swizzled classes to record redirects
 *
 *  @param task in flight network task
 *  @param arg1 redirect request
 *  @param arg2 response for redirect
 */
- (void)recordTask:(NSURLSessionTask *)task redirectRequest:(NSURLRequest *)arg1 redirectResponse:(NSURLResponse *)arg2;

/**
 *  Called by networking swizzled classes to record data received from the network request
 *
 *  @param task in flight network task
 *  @param data data received from network task
 */
- (void)recordTask:(NSURLSessionTask *)task didReceiveData:(NSData *)data;

/**
 *  Called by networking swizzled classes to record the response. May be called multiple times.
 *
 *  @param task in flight network task
 *  @param response Response received from server
 */
- (void)recordTask:(NSURLSessionTask *)task didReceiveResponse:(NSURLResponse *)response;
/**
 *  Called by networking swizzled classes to record any error if one is set for a 
 *  NSURLSessionTask. Error will only be passed if something goes wrong.
 *
 *  @param taskUniqueIdentifier unique identifier for in flight network task
 *  @param arg1 error from network request
 */
- (void)recordTask:(NSString *)taskUniqueIdentifier setError:(NSError *)error;

/**
 *  Called by networking swizzled classes so that after task recording block will
 *  execute.
 *
 *  @param task recently finished network task
 *  @param arg1 error or nil from network request
 */
- (void)recordTask:(NSURLSessionTask *)task didFinishWithError:(NSError *)arg1;


@end
