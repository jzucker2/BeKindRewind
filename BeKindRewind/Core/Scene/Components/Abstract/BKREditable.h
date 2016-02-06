//
//  BKREditable.h
//  Pods
//
//  Created by Jordan Zucker on 2/6/16.
//
//

#import <Foundation/Foundation.h>

@class BKRFrame;

/**
 *  This protocol is for normalizing a BKRFrame
 */
@protocol BKREditable <NSObject>

/**
 *  Returns of a normalized version of a BKRFrame as a subclass
 *
 *  @return newly initialized, normalized BKRFrame downcasted to the base BKRFrame class
 */
- (BKRFrame *)editedFrame;

@end
