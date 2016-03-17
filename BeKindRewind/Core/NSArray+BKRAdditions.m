//
//  NSArray+BKRAdditions.m
//  Pods
//
//  Created by Jordan Zucker on 3/17/16.
//
//

#import "NSArray+BKRAdditions.h"

@implementation NSArray (BKRAdditions)

- (NSArray *)BKR_select:(BOOL (^)(id obj))block
{
    NSParameterAssert(block != nil);
    return [self objectsAtIndexes:[self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return block(obj);
    }]];
}

@end
