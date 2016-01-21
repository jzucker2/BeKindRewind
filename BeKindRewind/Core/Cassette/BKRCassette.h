//
//  BKRCassette.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRPlistSerializing.h"

@class BKRRawFrame;
@class BKRScene;
@interface BKRCassette : NSObject <BKRPlistSerializing>

@property (nonatomic, getter=isRecording) BOOL recording;

- (void)addFrame:(BKRRawFrame *)frame;
- (NSArray<BKRScene *> *)allScenes;

@end
