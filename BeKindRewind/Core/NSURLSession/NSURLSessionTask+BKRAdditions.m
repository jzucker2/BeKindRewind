//
//  NSURLSessionTask+BKRAdditions.m
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <objc/runtime.h>
#import "NSURLSessionTask+BKRAdditions.h"

static const void *BKRTaskUniqueIDKey = &BKRTaskUniqueIDKey;

@implementation NSURLSessionTask (BKRAdditions)

@dynamic globallyUniqueIdentifier;

- (void)setGloballyUniqueIdentifier:(NSString *)globallyUniqueIdentifier {
    objc_setAssociatedObject(self, BKRTaskUniqueIDKey, globallyUniqueIdentifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)globallyUniqueIdentifier {
    return objc_getAssociatedObject(self, BKRTaskUniqueIDKey);
}

- (void)uniqueify {
    if (!self.globallyUniqueIdentifier) {
        self.globallyUniqueIdentifier = [NSUUID UUID].UUIDString;
    }
}

@end
