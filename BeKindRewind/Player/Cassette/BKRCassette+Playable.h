//
//  BKRCassette+Playable.h
//  Pods
//
//  Created by Jordan Zucker on 2/15/16.
//
//

#import "BKRCassette.h"
#import "BKRPlistSerializing.h"

/**
 *  This category is for playable-related functionality for a BKRCassette instance
 *
 *  @since 1.0.0
 */
@interface BKRCassette (Playable) <BKRPlistDeserializer>

/**
 *  Constructor for creating a BKRCassette instance from Foundation objects
 *
 *  @param dictionary contains Foundation objects with information to create a BKRCassette
 *
 *  @return newly initialized instance of BKRCassette
 *
 *  @since 1.0.0
 */
+ (instancetype)cassetteFromDictionary:(NSDictionary *)dictionary;

@end
