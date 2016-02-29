//
//  NSURLSessionTask+BKRAdditions.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <Foundation/Foundation.h>

/**
 *  This category extends NSURLSessionTask objects
 *  for easy recording
 */
@interface NSURLSessionTask (BKRAdditions)

/**
 *  This BKR_globabllyUniqueIdentifier is a NSString of an NSUUID for uniquefying all tasks we are recording.
 */
@property (nonatomic, copy) NSString *BKR_globallyUniqueIdentifier;

/**
 *  Sets a BKR_globallyUniqueIdentifier for correlating recordings if one was not already set
 */
- (void)BKR_uniqueify;

@end
