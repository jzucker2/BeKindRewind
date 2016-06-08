//
//  BKRNSURLSessionTask.h
//  Pods
//
//  Created by Jordan Zucker on 1/26/16.
//
//

#import <Foundation/Foundation.h>

/**
 *  This represents a NSURLSessionTask used for making
 *  network requests
 *
 *  @since 1.0.0
 */
@interface BKRNSURLSessionTask : NSObject

/**
 *  This overrides all NSURLSessionTask objects for recording
 *
 *  @since 1.0.0
 */
+ (void)swizzleNSURLSessionTask;

@end
