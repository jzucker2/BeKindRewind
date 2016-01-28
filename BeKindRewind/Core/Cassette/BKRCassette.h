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


@property (nonatomic) NSDate *creationDate;
@property (nonatomic) dispatch_queue_t processingQueue;

// this is definitely public
- (NSArray<BKRScene *> *)allScenes;
- (NSDictionary<NSString *, BKRScene *> *)scenesDictionary;
- (void)addSceneToScenesDictionary:(BKRScene *)scene;

@end
