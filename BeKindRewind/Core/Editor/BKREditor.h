//
//  BKREditor.h
//  Pods
//
//  Created by Jordan Zucker on 1/28/16.
//
//

#import <Foundation/Foundation.h>

@class BKRCassette;
@class BKRScene;

@interface BKREditor : NSObject

+ (instancetype)editor;

@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic) dispatch_queue_t editingQueue;

@property (nonatomic, strong) BKRCassette *currentCassette;


- (NSArray<BKRScene *> *)allScenes;

@end
