//
//  BKRNSURLSessionConnection.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <Foundation/Foundation.h>

/**
 *  This class represents an internal object in the NSURLSession class cluster
 *  that carries out the network request for a NSURLSessionTask
 */
@interface BKRNSURLSessionConnection : NSObject

/**
 *  All private NSURLSessionConnection objects have a strong reference to a task
 */
@property(copy) NSURLSessionTask *task; // @synthesize task=_task;

/**
 *  This method overrides all network calls with our custom recorder
 */
+ (void)swizzleNSURLSessionConnection;

@end
