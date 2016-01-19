//
//  BKRCassette.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <Foundation/Foundation.h>

//@class BKRScene;
@class BKRFrame;
@interface BKRCassette : NSObject

@property (nonatomic, getter=isRecording) BOOL recording;

//- (void)addScene:(BKRScene *)scene;
- (void)addFrame:(BKRFrame *)frame;
- (NSArray *)allScenes;

//- (NSArray *)allScenes;
//- (NSArray *)allScenesForPlist;

@end
