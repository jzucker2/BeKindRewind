//
//  BKRResponseStub+Private.h
//  Pods
//
//  Created by Jordan Zucker on 4/14/16.
//
//

#import "BKRResponseStub.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/**
 *  This is the private interface for the BKRResponseStub class.
 *
 *  @since 2.0.0
 */
@interface BKRResponseStub ()

/**
 *  This value is derived from recordings made by BeKindRewind and can be used
 *  while playing mocked network actions. It is the time elapsed between the
 *  beginning of a network request and the NSURLResponse being received. If
 *  any of this data is missing (e.g. a recording being truncated) then
 *  this value will be 0.0
 *
 *  @since 2.0.0
 */
@property (nonatomic, assign, readwrite) NSTimeInterval recordedRequestTime;

/**
 *  This value is derived from recordings made by BeKindRewind and can be used
 *  while playing mocked network actions. It is the total time elapsed for
 *  returning all the data associated with a network request, after the NSURLResponse
 *  is returned. If the response time cannot be calculated (e.g. a recording being
 *  truncated) then this value will be 0.0.
 *
 *  @note While the responseTime for a BKRResponseStub can be negative to represent
 *        speed, the recordedResponseTime will always be >= 0.
 *
 *  @note This will be 0.0 for a redirect because no data is returned during a redirect
 *
 *  @since 2.0.0
 */
@property (nonatomic, assign, readwrite) NSTimeInterval recordedResponseTime;

@end

NS_ASSUME_NONNULL_END
