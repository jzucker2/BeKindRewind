//
//  BKRPlistSerializing.h
//  Pods
//
//  Created by Jordan Zucker on 1/20/16.
//
//

#import <Foundation/Foundation.h>

@protocol BKRPlistSerializer <NSObject>

// guaranteed to work in plist
- (NSDictionary *)plistDictionary;

@end

@protocol BKRPlistDeserializer <NSObject>

- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary;

@end

@protocol BKRPlistSerializing <BKRPlistSerializer, BKRPlistDeserializer>

@end
