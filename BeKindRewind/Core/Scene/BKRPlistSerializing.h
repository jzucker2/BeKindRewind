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
 */
@protocol BKRPlistSerializer <NSObject>

/**
 *  This object is guaranteed to contain only plist encodable objects
 *
 *  @return dictionary containing only plist encodable objects
 */
- (NSDictionary *)plistDictionary;

@end

/**
 *  Protocol is used to turn plist dictionary objects into BeKindRewind objects
 */
@protocol BKRPlistDeserializer <NSObject>

/**
 *  Designated initializer used for creating BeKindRewind objects from plist
 *  dictionaries.
 *
 *  @param dictionary contains only objects that be plist encoded
 *
 *  @return returns a BeKindRewind object
 */
- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary;

@end

/**
 *  The BKRPlistSerializing protocol adopts both the BKRPlistSerializer protocol and
 *  the BKRPlistDeserializer protocol
 */
@protocol BKRPlistSerializing <BKRPlistSerializer, BKRPlistDeserializer>

@end
