//
//  BKRRawFrame+Playable.h
//  Pods
//
//  Created by Jordan Zucker on 2/12/16.
//
//

#import "BKRRawFrame.h"

/**
 *  This is category is used for turning Foundation objects associated with
 *  a network request into a normalized, concrete BKRFrame subclass for proper handling
 *  by the BKRPlayer instance
 */
@interface BKRRawFrame (Playable) <BKRPlistDeserializer>

/**
 *  This is a normalized version of a BKRFrame concrete subclass created from the information
 *  contained by the reciever
 *
 *  @return newly initialized instance of a concrete subclass of BKRFrame
 */
- (BKRFrame *)editedPlaying;

@end
