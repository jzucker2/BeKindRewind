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

#warning add docs
- (NSTimeInterval)creationTimestamp;
- (NSTimeInterval)timeSinceCreationForFrame:(BKRFrame *)frame;
- (NSTimeInterval)timeSinceCreationForFrameIndex:(NSUInteger)frameIndex;

- (NSTimeInterval)recordedRequestTimeForFinalResponseStub;
- (NSTimeInterval)recordedResponseTimeForFinalResponseStub;
- (NSTimeInterval)recordedRequestTimeForRedirectFrame:(BKRRedirectFrame *)redirectFrame;
- (NSTimeInterval)recordedResponseTimeForRedirectFrame:(BKRRedirectFrame *)redirectFrame;
@end
