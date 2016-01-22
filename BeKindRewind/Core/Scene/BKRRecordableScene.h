//
//  BKRRecordableScene.h
//  Pods
//
//  Created by Jordan Zucker on 1/21/16.
//
//

#import "BKRPlistSerializing.h"
#import "BKRScene.h"

@class BKRRawFrame;
@interface BKRRecordableScene : BKRScene <BKRPlistSerializing>

- (instancetype)initFromFrame:(BKRRawFrame *)frame;
+ (instancetype)sceneFromFrame:(BKRRawFrame *)frame;
- (void)addFrame:(BKRRawFrame *)frame;

@end
