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
 */
@interface BKRScene (Playable) <BKRPlistDeserializer>

/**
 *  This is the number of redirects associated with this scene.
 *
 *  @return number of times this should redirect.
 */
- (NSUInteger)numberOfRedirects;

/**
 *  Convenience method for checking whether a scene contains redirects.
 *
 *  @return If `YES` then the scene contains redirect responses. If `NO` 
 *          then it contains no redirect responses.
 */
- (BOOL)hasRedirects;

/**
 *  Represents the last response for a scene (which includes any final error or data).
 *
 *  @return response stub to mock a request
 */
- (BKRResponseStub *)finalResponseStub;

/**
 *  Represents a redirect response for a scene (constructed from a 
 *  BKRRedirectFrame instance contained within the scene).
 *
 *  @param redirectFrame this should be contained by the receiver
 *
 *  @return stub to mock a redirect for a request
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
 */
- (BKRRequestFrame *)requestFrameForRedirect:(NSUInteger)redirectNumber;

/**
 *  This represents information associated with a specific redirect contained by the receiver.
 *
 *  @param redirectNumber the specific redirect to look for
 *
 *  @return returns the an instance of BKRRedirectFrame associated with this redirectNumber.
 *          This will be nil if there is no redirect for redirectNumber
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
 */
- (BKRResponseStub *)responseStubForRedirect:(NSUInteger)redirectNumber;

@end
