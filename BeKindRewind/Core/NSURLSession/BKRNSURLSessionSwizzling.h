//
//  BKRNSURLSessionSwizzling.h
//  Pods
//
//  Created by Jordan Zucker on 2/5/16.
//
//

#import <Foundation/Foundation.h>

/**
 *  This class cluster represents all NSURLSession related swizzling
 *  for easy recording
 *
 *  @since 1.0.0
 */
@interface BKRNSURLSessionSwizzling : NSObject

/**
 *  Override all NSURLSession related methods for easy recording
 *
 *  @since 1.0.0
 */
+ (void)swizzleForRecording;

@end
