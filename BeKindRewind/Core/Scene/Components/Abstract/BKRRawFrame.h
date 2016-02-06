//
//  BKRRawFrame.h
//  Pods
//
//  Created by Jordan Zucker on 1/20/16.
//
//

#import "BKRFrame.h"

/**
 *  This is a basic weakly typed component of a network activity
 *  containing a single piece of information (possibly data, a response, a request, etc.)
 */
@interface BKRRawFrame : BKRFrame

/**
 *  Single element of network activity contained by this frame.
 */
@property (nonatomic, copy) id item;

@end
