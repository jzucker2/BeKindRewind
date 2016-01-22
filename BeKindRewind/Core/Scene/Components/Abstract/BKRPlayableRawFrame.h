//
//  BKRPlayableRawFrame.h
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import "BKRRawFrame.h"

@interface BKRPlayableRawFrame : BKRRawFrame <BKRPlistDeserializer>

- (BKRFrame *)editedFrame;

@end
