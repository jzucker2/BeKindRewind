//
//  BKRRawFrame+Playable.h
//  Pods
//
//  Created by Jordan Zucker on 2/12/16.
//
//

#import "BKRRawFrame.h"

/**
 *  This is a raw network component from a plist dictionary that needs
 *  to be normalized into a concrete BKRFrame subclass for proper handling
 *  by the BKRPlayer instance
 */
@interface BKRRawFrame (Playable) <BKRPlistDeserializer>

- (BKRFrame *)editedPlaying;

@end
