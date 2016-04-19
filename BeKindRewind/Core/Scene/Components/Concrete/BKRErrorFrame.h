//
//  BKRErrorFrame.h
//  Pods
//
//  Created by Jordan Zucker on 1/25/16.
//
//

#import "BKRFrame.h"
#import "BKRPlistSerializing.h"

/**
 *  Concrete subclass of BKRFrame representing a NSError associated with a network operation
 *
 *  @since 1.0.0
 */
@interface BKRErrorFrame : BKRFrame <BKRPlistSerializing>

/**
 *  Add the error that this subclass of BKRFrame is meant to represent. This class will store
 *  any useful or necessary information associated with the error.
 *
 *  @param error received from server response
 *
 *  @since 1.0.0
 */
- (void)addError:(NSError *)error;

/**
 *  Generate a NSError from the information contained within this class
 *
 *  @since 1.0.0
 */
@property (nonatomic, readonly) NSError *error;

/**
 *  The error code associated with the NSError object
 *
 *  @since 1.0.0
 */
@property (nonatomic, readonly) NSInteger code;

/**
 *  The domain associated with the NSError object represented by this class. Typically
 *  the domain is NSURLErrorDomain
 *
 *  @since 1.0.0
 */
@property (nonatomic, copy, readonly) NSString *domain;

/**
 *  Any userInfo associated with the NSError object represented by this class.
 *
 *  @since 1.0.0
 */
@property (nonatomic, readonly) NSDictionary *userInfo;
#warning docs
@property (nonatomic, readonly) NSURL *failingURL;
@property (nonatomic, readonly) NSString *failingURLString;

@end
