//
//  BKRSerializer.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <Foundation/Foundation.h>

@protocol BKRSerializer <NSObject>

// guaranteed to work in plist
- (NSDictionary *)plistRepresentation;

@end
