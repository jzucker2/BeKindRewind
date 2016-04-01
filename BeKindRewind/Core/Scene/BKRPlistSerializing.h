//
//  BKRPlistSerializing.h
//  Pods
//
//  Created by Jordan Zucker on 1/20/16.
//
//

#import <Foundation/Foundation.h>

/**
 *  Protocol is used to turn BeKindRewind objects into plist dictionaries for storage
 *
 *  @since 1.0.0
 */
@protocol BKRPlistSerializer <NSObject>

/**
 *  This object is guaranteed to contain only plist encodable objects
 *
 *  @return dictionary containing only plist encodable objects
 *
 *  @since 1.0.0
 */
- (NSDictionary *)plistDictionary;

@end

/**
 *  Protocol is used to turn plist dictionary objects into BeKindRewind objects
 *
 *  @since 1.0.0
 */
@protocol BKRPlistDeserializer <NSObject>

/**
 *  Designated initializer used for creating BeKindRewind objects from plist
 *  dictionaries.
 *
 *  @param dictionary contains only objects that be plist encoded
 *
 *  @return returns a BeKindRewind object
 *
 *  @since 1.0.0
 */
- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary;

@end

/**
 *  The BKRPlistSerializing protocol adopts both the BKRPlistSerializer protocol and
 *  the BKRPlistDeserializer protocol
 *
 *  @since 1.0.0
 */
@protocol BKRPlistSerializing <BKRPlistSerializer, BKRPlistDeserializer>

@end
