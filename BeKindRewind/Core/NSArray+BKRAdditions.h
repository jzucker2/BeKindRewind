//
//  NSArray+BKRAdditions.h
//  Pods
//
//  Created by Jordan Zucker on 3/17/16.
//
//

#import <Foundation/Foundation.h>

@interface NSArray (BKRAdditions)

/**
 *  Loops through an array to find the objects matching the block.
 *
 *  @param block A single-argument, BOOL-returning code block.
 *
 *  @return Returns an array of the objects found.
 */
- (NSArray *)BKR_select:(BOOL (^)(id obj))block;

@end
