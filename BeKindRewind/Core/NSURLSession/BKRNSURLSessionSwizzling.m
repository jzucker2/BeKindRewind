//
//  BKRNSURLSessionSwizzling.m
//  Pods
//
//  Created by Jordan Zucker on 2/5/16.
//
//

#import "BKRNSURLSessionSwizzling.h"
#import "BKRNSURLSessionConnection.h"
#import "BKRNSURLSessionTask.h"

@implementation BKRNSURLSessionSwizzling

+ (void)swizzleForRecording {
    [BKRNSURLSessionConnection swizzleNSURLSessionConnection];
    [BKRNSURLSessionTask swizzleNSURLSessionTask];
}

@end
