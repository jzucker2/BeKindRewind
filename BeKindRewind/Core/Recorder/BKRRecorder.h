//
//  BKRRecorder.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRConstants.h"
#import "BKRVCRActions.h"
#import "BKRPlistSerializing.h"

@class BKRCassette;
@class BKRScene;

/**
 *  This object is responsible for collecting and storing all information associated
 *  with a network request.
 */
@interface BKRRecorder : NSObject <BKRVCRRecording, BKRPlistSerializer>

/**
 *  Whether or not network activity should be recorded
 */
@property (nonatomic, getter=isEnabled) BOOL enabled;

/**
 *  This updates the enabled property of the receiver's custom queue. It calls the 
 *  completionBlock on the receiver's queue after the property is updated.
 *
 *  @param enabled         whether the BKRRecorder should record network events
 *  @param completionBlock this is called on the receiver's queue after updating the property
 */
- (void)setEnabled:(BOOL)enabled withCompletionHandler:(void (^)(void))completionBlock;

/**
 *  This is set if the receiver recorded an event while it was enabled.
 */
@property (nonatomic, assign, readonly) BOOL didRecord;

/**
 *  Current cassette used to store network requests. If this is nil,
 *  then no recordings are stored.
 */
@property (nonatomic, strong) BKRCassette *currentCassette;

/**
 *  Ordered array of BKRRecordableScene objects from current cassette
 *
 *  @return ordered array by creation date of each scene or nil if no current cassette
 */
- (NSArray<BKRScene *> *)allScenes;

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
- (void)resetWithCompletionBlock:(void (^)(void))completionBlock;

/**
 *  Called by networking swizzled classes to begin recording
 *  for a task by executing the beginRecordingBlock
 *
 *  @param task NSURLSessionTask that just began executing
 */
- (void)beginRecording:(NSURLSessionTask *)task;

/**
 *  Called by networking swizzled classes to record redirects
 *
 *  @param task in flight network task
 *  @param request redirect request
 *  @param response response for redirect
 */
- (void)recordTask:(NSURLSessionTask *)task redirectRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response;

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
- (void)recordTask:(NSURLSessionTask *)task setError:(NSError *)error;

/**
 *  Called by networking swizzled classes so that after task recording block will
 *  execute.
 *
 *  @param task recently finished network task
 *  @param arg1 error or nil from network request
 */
- (void)recordTask:(NSURLSessionTask *)task didFinishWithError:(NSError *)error;

/**
 *  Called by network to record requests associated with a network event. This
 *  covers the originalRequest and the currentRequest associated with the task
 *
 *  @param task    executing network task
 *  @param request request associated with the network task
 */
- (void)recordTask:(NSURLSessionTask *)task didAddRequest:(NSURLRequest *)request;


@end
