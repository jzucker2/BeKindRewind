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
 */
@interface BKRErrorFrame : BKRFrame <BKRPlistSerializing>

/**
 *  Add the error that this subclass of BKRFrame is meant to represent. This class will store
 *  any useful or necessary information associated with the error.
 *
 *  @param error received from server response
 */
- (void)addError:(NSError *)error;

/**
 *  Generate a NSError from the information contained within this class
 */
@property (nonatomic, readonly) NSError *error;

/**
 *  The error code associated with the NSError object
 */
@property (nonatomic, readonly) NSInteger code;

/**
 *  The domain associated with the NSError object represented by this class. Typically
 *  the domain is NSURLErrorDomain
 */
@property (nonatomic, copy, readonly) NSString *domain;

/**
 *  Any userInfo associated with the NSError object represented by this class.
 */
@property (nonatomic, readonly) NSDictionary *userInfo;

@end
