//
//  NSArray+BKRAdditions.m
//  Pods
//
//  Created by Jordan Zucker on 3/17/16.
//
//

#import "NSArray+BKRAdditions.h"

@implementation NSArray (BKRAdditions)

- (NSArray *)BKR_select:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);
    return [self objectsAtIndexes:[self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return block(obj);
    }]];
}

- (id)BKR_match:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    NSUInteger index = [self indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return block(obj);
    }];
    
    if (index == NSNotFound)
        return nil;
    
    return self[index];
}

- (BOOL)BKR_any:(BOOL (^)(id obj))block {
    return [self BKR_match:block] != nil;
}

@end
