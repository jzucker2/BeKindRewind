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

@dynamic BKR_globallyUniqueIdentifier;

- (void)setBKR_globallyUniqueIdentifier:(NSString *)globallyUniqueIdentifier {
    objc_setAssociatedObject(self, BKRTaskUniqueIDKey, globallyUniqueIdentifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)BKR_globallyUniqueIdentifier {
    return objc_getAssociatedObject(self, BKRTaskUniqueIDKey);
}

- (void)BKR_uniqueify {
    if (!self.BKR_globallyUniqueIdentifier) {
        self.BKR_globallyUniqueIdentifier = [NSUUID UUID].UUIDString;
    }
}

@end
