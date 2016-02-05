//
//  BKRNSURLSessionConnection.m
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//
#if TARGET_OS_IOS
    #import <UIKit/UIKit.h>
#endif

#import <objc/runtime.h>
#import "BKRRecorder.h"
#import "BKRNSURLSessionConnection.h"
#import "NSURLSessionTask+BKRAdditions.h"

// For reference from the private class dump
//@interface __NSCFURLSessionConnection : NSObject
//
//- (void)_redirectRequest:(id)arg1 redirectResponse:(id)arg2 completion:(void (^)(id arg))arg3;
//- (void)_conditionalRequirementsChanged:(BOOL)arg1;
//- (void)_connectionIsWaiting;
//- (void)_willSendRequestForEstablishedConnection:(id)arg1 completion:(void (^)(NSURLRequest *arg3))arg2;
//- (void)_didReceiveConnectionCacheKey:(struct HTTPConnectionCacheKey *)arg1;
//- (void)_didFinishWithError:(id)arg1;
//- (void)_didSendBodyData:(struct UploadProgressInfo)arg1;
//- (void)_didReceiveData:(id)arg1;
//- (void)_didReceiveResponse:(id)arg1 sniff:(BOOL)arg2;
//
//@end

@implementation BKRNSURLSessionConnection
@dynamic task;

+ (void)swizzleNSURLSessionConnection
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self _swizzleNSURLSessionConnection];
    });
}

+ (void)_swizzleNSURLSessionConnection;
{
    NSString *overrideSessionConnectionClassString = nil;
#if TARGET_OS_IOS
    if ([[[UIDevice currentDevice] systemVersion] hasPrefix:@"8"]) {
        overrideSessionConnectionClassString = @"__NSCFURLSessionConnection";
    } else {
        overrideSessionConnectionClassString = @"__NSCFURLLocalSessionConnection";
    }
#else
    overrideSessionConnectionClassString = @"__NSCFURLLocalSessionConnection";
#endif
    Class cfURLSessionConnectionClass = NSClassFromString(overrideSessionConnectionClassString);
    if (!cfURLSessionConnectionClass) {
        NSLog(@"Could not find __NSCFURLSessionConnection. It is possible that JSZVCR cannot yet record in this configuration. Please try another platform, system version, or device type.");
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

- (instancetype)BKR_initWithTask:(NSURLSessionTask *)task delegate:(id <NSURLSessionDelegate>)delegate delegateQueue:(NSOperationQueue *)queue {
    [task uniqueify];
    [[BKRRecorder sharedInstance] initTask:task];
    return [self BKR_initWithTask:task delegate:delegate delegateQueue:queue];
}

- (void)BKR__redirectRequest:(NSURLRequest *)arg1 redirectResponse:(NSURLResponse *)arg2 completion:(id)arg3;
{
    [self.task uniqueify];
    [[BKRRecorder sharedInstance] recordTask:self.task redirectRequest:arg1 redirectResponse:arg2];
    [self BKR__redirectRequest:arg1 redirectResponse:arg2 completion:arg3];
}

- (void)BKR__didReceiveData:(id)data;
{
    [self.task uniqueify];
    [[BKRRecorder sharedInstance] recordTask:self.task didReceiveData:data];
    [self BKR__didReceiveData:data];
}

- (void)BKR__didReceiveResponse:(NSURLResponse *)response sniff:(BOOL)sniff;
{
    [self.task uniqueify];
    // This can be called multiple times for the same request. Make sure it doesn't
    [[BKRRecorder sharedInstance] recordTask:self.task didReceiveResponse:response];
    [self BKR__didReceiveResponse:response sniff:sniff];
}

- (void)BKR__didFinishWithError:(NSError *)error;
{
    [self.task uniqueify];
    [[BKRRecorder sharedInstance] recordTask:self.task didFinishWithError:error];
    [self BKR__didFinishWithError:error];
}

@end
