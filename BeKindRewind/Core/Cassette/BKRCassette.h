//
//  BKRCassette.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRPlistSerializing.h"

@class BKRScene;
@interface BKRCassette : NSObject <BKRPlistSerializing>


// possibly make these private header properties
@property (nonatomic, strong) NSMutableDictionary *scenes;
@property (nonatomic) NSDate *creationDate;

// this is definitely public
- (NSArray<BKRScene *> *)allScenes;

@end
