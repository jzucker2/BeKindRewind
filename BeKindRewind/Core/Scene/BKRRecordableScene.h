//
//  BKRRecordableScene.h
//  Pods
//
//  Created by Jordan Zucker on 1/21/16.
//
//

#import "BKRPlistSerializing.h"
#import "BKRScene.h"

@class BKRRecordableRawFrame;
@interface BKRRecordableScene : BKRScene <BKRPlistSerializer>

- (instancetype)initFromFrame:(BKRRecordableRawFrame *)frame;
+ (instancetype)sceneFromFrame:(BKRRecordableRawFrame *)frame;
- (void)addFrame:(BKRRecordableRawFrame *)frame;

@end
