//
//  BKRCassette+Playable.h
//  Pods
//
//  Created by Jordan Zucker on 2/15/16.
//
//

#import "BKRCassette.h"
#import "BKRPlistSerializing.h"

@interface BKRCassette (Playable) <BKRPlistDeserializer>

+ (instancetype)cassetteFromDictionary:(NSDictionary *)dictionary;

@end
