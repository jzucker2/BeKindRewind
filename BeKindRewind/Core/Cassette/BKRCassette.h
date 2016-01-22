//
//  BKRCassette.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <Foundation/Foundation.h>

@class BKRScene;
@interface BKRCassette : NSObject


// possibly make these private header properties
@property (nonatomic, strong) NSDictionary<NSString *, BKRScene *> *scenes;
@property (nonatomic) NSDate *creationDate;
@property (nonatomic) dispatch_queue_t processingQueue;

// this is definitely public
- (NSArray<BKRScene *> *)allScenes;

@end
