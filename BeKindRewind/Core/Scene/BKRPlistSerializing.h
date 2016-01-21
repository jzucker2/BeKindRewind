//
//  BKRPlistSerializing.h
//  Pods
//
//  Created by Jordan Zucker on 1/20/16.
//
//

#import <Foundation/Foundation.h>

@protocol BKRPlistSerializing <NSObject>

// guaranteed to work in plist
- (NSDictionary *)plistDictionary;

- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary;

@end
