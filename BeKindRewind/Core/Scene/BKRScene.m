//
//  BKRScene.m
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import "NSURLSessionTask+BKRAdditions.h"
#import "BKRScene.h"
#import "BKRData.h"
#import "BKRRequest.h"
#import "BKRResponse.h"


@implementation BKRScene

- (instancetype)initWithTask:(NSURLSessionTask *)task {
    self = [super init];
    if (self) {
        _uniqueIdentifier = task.globallyUniqueIdentifier;
    }
    return self;
}

+ (instancetype)sceneWithTask:(NSURLSessionTask *)task {
    return [[self alloc] initWithTask:task];
}

- (void)addData:(NSData *)data {
    
}

- (void)addRequest:(NSURLRequest *)request {
    
}

- (void)addResponse:(NSURLResponse *)response {
    
}

@end
