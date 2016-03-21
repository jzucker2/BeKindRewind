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

/** Loops through an array to find whether any object matches the block.
 This method is similar to the Scala list `exists`. It is functionally
 identical to bk_match: but returns a `BOOL` instead. It is not recommended
 to use bk_any: as a check condition before executing bk_match:, since it would
 require two loops through the array.
 For example, you can find if a string in an array starts with a certain letter:
 NSString *letter = @"A";
 BOOL containsLetter = [stringArray bk_any:^(id obj) {
 return [obj hasPrefix:@"A"];
 }];
 @param block A single-argument, BOOL-returning code block.
 @return YES for the first time the block returns YES for an object, NO otherwise.
 */
- (BOOL)BKR_any:(BOOL (^)(id obj))block;

@end
