//
//  BKRPlayableCassette.h
//  Pods
//
//  Created by Jordan Zucker on 1/21/16.
//
//

#import "BKRCassette.h"
#import "BKRPlistSerializing.h"

@interface BKRPlayableCassette : BKRCassette <BKRPlistDeserializer>

@property (nonatomic, getter=isPlaying) BOOL playing;

@end
