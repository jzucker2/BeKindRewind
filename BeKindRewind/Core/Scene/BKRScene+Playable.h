//
//  BKRScene+Playable.h
//  Pods
//
//  Created by Jordan Zucker on 2/12/16.
//
//

#import "BKRScene.h"
#import "BKRPlistSerializing.h"

@class BKRResponseStub;

/**
 *  This category handles the data associated with a network
 *  request and is intended to be used for stubbing.
 *
 *  @since 1.0.0
 */
@interface BKRScene (Playable) <BKRPlistDeserializer>

/**
 *  This is the number of redirects associated with this scene.
 *
 *  @return number of times this should redirect.
 *
 *  @since 1.0.0
 */
- (NSUInteger)numberOfRedirects;

/**
 *  Convenience method for checking whether a scene contains redirects.
 *
 *  @return If `YES` then the scene contains redirect responses. If `NO` 
 *          then it contains no redirect responses.
 *
 *  @since 1.0.0
 */
- (BOOL)hasRedirects;

/**
 *  Convenience method for checking whether a scene ends in a NSError
 *
 *  @return If `YES` then the scene ends in an error (returns a NSError as
 *          as a response to a network request).
 *
 *  @since 2.0.0
 */
- (BOOL)isError;

/**
 *  Represents the last response for a scene (which includes any final error or data).
 *
 *  @return response stub to mock a request
 *
 *  @since 1.0.0
 */
- (BKRResponseStub *)finalResponseStub;

/**
 *  Represents a redirect response for a scene (constructed from a 
 *  BKRRedirectFrame instance contained within the scene).
 *
 *  @param redirectFrame this should be contained by the receiver
 *
 *  @return stub to mock a redirect for a request
 *
 *  @since 1.0.0
 */
- (BKRResponseStub *)responseStubForRedirectFrame:(BKRRedirectFrame *)redirectFrame;

/**
 *  This represents information associated with a specific redirect contained by the receiver.
 *
 *  @param redirectNumber the specific redirect to look for
 *
 *  @return returns the an instance of BKRRequestFrame associated with the 
 *          BKRRedirectFrame representing this redirectNumber. This will be nil
 *          if there is no redirect for redirectNumber
 *
 *  @since 1.0.0
 */
- (BKRRequestFrame *)requestFrameForRedirect:(NSUInteger)redirectNumber;

/**
 *  This represents information associated with a specific redirect contained by the receiver.
 *
 *  @param redirectNumber the specific redirect to look for
 *
 *  @return returns the an instance of BKRRedirectFrame associated with this redirectNumber.
 *          This will be nil if there is no redirect for redirectNumber
 *
 *  @since 1.0.0
 */
- (BKRRedirectFrame *)redirectFrameForRedirect:(NSUInteger)redirectNumber;

/**
 *  This creates a response stub that represents information associated with a 
 *  specific redirect contained by the receiver.
 *
 *  @param redirectNumber the specific redirect to look for
 *
 *  @return returns the a response stub associated with this redirectNumber.
 *          This will be nil if there is no redirect for redirectNumber
 *
 *  @since 1.0.0
 */
- (BKRResponseStub *)responseStubForRedirect:(NSUInteger)redirectNumber;

/**
 *  This is the unix timestamp (timeSince1970) of the first
 *  frame in the scene
 *
 *  @return time elapsed as an NSTimeInterval value
 *
 *  @since 2.0.0
 */
- (NSTimeInterval)creationTimestamp;

/**
 *  This is the unix timestamp (timeSince1970) of frame if
 *  it exists in the scene
 *
 *  @param frame instance of BKRFrame to calculate timestamp for. This
 *  @throws NSInternalInconsistency exception if filePath is nil
 *
 *  @return time elapsed as an NSTimeInterval value or 0.0 if frame is not within this scene
 *
 *  @since 2.0.0
 */
- (NSTimeInterval)timeSinceCreationForFrame:(BKRFrame *)frame;

/**
 *  The duration to wait before faking receiving the response headers
 *  for the final response (data or an error). This is the actual 
 *  value applied to a mocked network action during playing. It 
 *  represents the time elapsed between a network request
 *  beginning and the final NSURLResponse being received.
 *
 *  @return this returns the duration or 0.0 if there is no response
 *          frame (e.g. the recording is truncated)
 *
 *  @since 2.0.0
 */
- (NSTimeInterval)recordedRequestTimeForFinalResponseStub;

/**
 *  The duration to use to send the fake response body for the final response 
 *  (data or an error). This is the actual value applied to a mocked network
 *  action during playing. It represents the time that elapsed for all the data
 *  for a network action that is returned for a request.
 *
 *  @return this returns the duration (as a NSTimeInterval value) or 0.0 
 *          if there is no data frame (e.g. the recording is truncated)
 *
 *  @since 2.0.0
 */
- (NSTimeInterval)recordedResponseTimeForFinalResponseStub;

/**
 *  The duration to wait before faking receiving the response headers
 *  for a redirect response matching the redirectFrame parameter. This
 *  is the actual value applied to a mocked network action during playing. 
 *  It represents the time elapsed between a network request
 *  beginning and a redirect response matching redirectFrame being received
 *
 *  @param redirectFrame frame to calculate redirect time elapsed for
 *  @throws NSInternalInconsistency exception if filePath is nil
 *
 *  @return this returns the duration as NSTimeInterval value or 0.0 if 
 *          there is no redirectFrame (e.g. the recording is truncated)
 *
 *  @since 2.0.0
 */
- (NSTimeInterval)recordedRequestTimeForRedirectFrame:(BKRRedirectFrame *)redirectFrame;

/**
 *  This is the duration to wait to return all the data associated with a redirect.
 *  Since redirects only contain a request and a response, this is always 0.0 seconds
 *
 *  @param redirectFrame frame to calculate duration for
 *
 *  @return this always returns an NSTimeInterval of 0.0
 *
 *  @since 2.0.0
 */
- (NSTimeInterval)recordedResponseTimeForRedirectFrame:(BKRRedirectFrame *)redirectFrame;

@end
