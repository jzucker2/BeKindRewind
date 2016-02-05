//
//  BKRNSURLSessionTask.m
//  Pods
//
//  Created by Jordan Zucker on 1/26/16.
//
//

#if TARGET_OS_IPHONE
    #import <UIKit/UIKit.h>
#endif

#import <objc/runtime.h>
#import "BKRRecorder.h"
#import "NSURLSessionTask+BKRAdditions.h"
#import "BKRNSURLSessionTask.h"

@implementation BKRNSURLSessionTask

+ (void)swizzleNSURLSessionTask {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self _swizzleNSURLSessionTask];
    });
}

+ (void)_swizzleNSURLSessionTask {
    NSString *overrideSessionConnectionClassString = nil;
#if TARGET_OS_IOS
    if ([[[UIDevice currentDevice] systemVersion] hasPrefix:@"8"]) {
        overrideSessionConnectionClassString = @"NSURLSessionTask";
    } else {
        overrideSessionConnectionClassString = @"__NSCFURLSessionTask";
    }
#else
    overrideSessionConnectionClassString = @"__NSCFURLSessionTask";
#endif
    Class cfURLSessionConnectionClass = NSClassFromString(overrideSessionConnectionClassString);
    if (!cfURLSessionConnectionClass) {
        NSLog(@"Could not find __NSCFURLSessionTask. It is possible that BeKindRewind cannot yet record in this configuration. Please try another platform, system version, or device type.");
        return;
    }
    
    unsigned int outCount = 0;
    Method *methods = class_copyMethodList([self class], &outCount);
    //    Method *methods = class_copyMethodList(cfURLSessionConnectionClass, &outCount);
    
    for (int i = 0; i < outCount; i++) {
        Method m = methods[i];
        SEL sourceMethod = method_getName(m);
        const char *encoding = method_getTypeEncoding(m);
        NSString *sourceMethodName = NSStringFromSelector(sourceMethod);
//        NSLog(@"%@", sourceMethodName);
        NSAssert([sourceMethodName hasPrefix:@"BKR_"], @"Expecting swizzle methods only");
        NSString *originalMethodName = [sourceMethodName substringFromIndex:4];
        SEL originalMethod = NSSelectorFromString(originalMethodName);
        NSAssert(originalMethod, @"Must find selector");
        
        IMP sourceImp = method_getImplementation(m);
        
        IMP originalImp = class_getMethodImplementation(cfURLSessionConnectionClass, originalMethod);
        
        NSAssert(originalImp, @"Must find imp");
        
        __unused BOOL success = class_addMethod(cfURLSessionConnectionClass, sourceMethod, originalImp, encoding);
        NSAssert(success, @"Should be successful");
        __unused IMP replacedImp = class_replaceMethod(cfURLSessionConnectionClass, originalMethod, sourceImp, encoding);
        NSAssert(replacedImp, @"Expected original method to have been replaced");
    }
    
    if (methods) {
        free(methods);
    }
}

- (void)BKR_setError:(id)arg1 {
    [[BKRRecorder sharedInstance] recordTask:[(NSURLSessionTask *)self globallyUniqueIdentifier] setError:arg1];
    [self BKR_setError:arg1];
}

- (void)BKR_resume {
    [(NSURLSessionTask *)self uniqueify];
    [[BKRRecorder sharedInstance] beginRecording:(NSURLSessionTask *)self];
    [self BKR_resume];
}

@end
