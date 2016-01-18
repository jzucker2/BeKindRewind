//
//  NSURLSessionTask+BKRAdditions.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <Foundation/Foundation.h>

@interface NSURLSessionTask (BKRAdditions)

/**
 *  This globabllyUniqueIdentifier is a NSString of an NSUUID for uniquefying all tasks we are recording.
 */
@property (nonatomic, copy) NSString *globallyUniqueIdentifier;

/**
 *  Sets a globallyUniqueIdentifier for correlating recordings if one was not already set
 */
- (void)uniqueify;

@end
