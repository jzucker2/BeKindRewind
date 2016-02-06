//
//  BKRPlayableRawFrame.h
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import "BKRRawFrame.h"
#import "BKREditable.h"

/**
 *  This is a raw network component from a plist dictionary that needs
 *  to be normalized into a concrete BKRFrame subclass for proper handling
 *  by the BKRPlayer instance
 */
@interface BKRPlayableRawFrame : BKRRawFrame <BKRPlistDeserializer, BKREditable>

@end
