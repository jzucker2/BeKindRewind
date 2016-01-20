//
//  BKRCassette.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRSerializer.h"

//@class BKRScene;
@class BKRFrame;
@interface BKRCassette : NSObject <BKRSerializer>

@property (nonatomic, getter=isRecording) BOOL recording;

- (void)addFrame:(BKRFrame *)frame;
- (NSArray *)allScenes;

@end
