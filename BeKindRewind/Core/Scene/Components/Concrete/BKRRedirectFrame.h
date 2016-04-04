//
//  BKRRedirectFrame.h
//  Pods
//
//  Created by Jordan Zucker on 3/4/16.
//
//

#import "BKRFrame.h"
#import "BKRPlistSerializing.h"

@class BKRRequestFrame;
@class BKRResponseFrame;

/**
 *  Concrete subclass of BKRFrame representing a redirect associated with a network operation
 *
 *  @since 1.0.0
 */
@interface BKRRedirectFrame : BKRFrame <BKRPlistSerializing>

/**
 *  Add the request that this subclass of BKRFrame is meant to represent. This class will store
 *  any useful or necessary information associated with the request.
 *
 *  @param request received from redirect server response.
 *
 *  @since 1.0.0
 */
- (void)addRequest:(NSURLRequest *)request;

/**
 *  Add the response that this subclass of BKRFrame is meant to represent. This class will store
 *  any useful or necessary information associated with the response.
 *
 *  @param response received from server as part of the redirect
 *
 *  @since 1.0.0
 */
- (void)addResponse:(NSURLResponse *)response;

/**
 *  The request frame associated with this redirect.
 *
 *  @since 1.0.0
 */
@property (nonatomic, strong, readonly) BKRRequestFrame *requestFrame;

/**
 *  The response frame associated with this redirect.
 *
 *  @since 1.0.0
 */
@property (nonatomic, strong, readonly) BKRResponseFrame *responseFrame;

@end
