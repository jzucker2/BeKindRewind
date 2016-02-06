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
 */
@interface BKRNSURLSessionTask : NSObject

/**
 *  This overrides all NSURLSessionTask objects for recording
 */
+ (void)swizzleNSURLSessionTask;

@end
