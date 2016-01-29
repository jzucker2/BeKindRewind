//
//  BKRCassetteHandler.h
//  Pods
//
//  Created by Jordan Zucker on 1/28/16.
//
//

#import <Foundation/Foundation.h>

@class BKRCassette;
@class BKRScene;

// used as super class for BKRRecorder and BKRPlayer
@interface BKRCassetteHandler : NSObject

+ (instancetype)handler;

@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic) dispatch_queue_t processingQueue;

@property (nonatomic, strong) BKRCassette *currentCassette;
//- (void)setCassette:(BKRCassette *)cassette;


- (NSArray<BKRScene *> *)allScenes;


@end
