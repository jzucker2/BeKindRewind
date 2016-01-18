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

- (void)addScene:(BKRScene *)scene;

- (NSArray *)allScenes;
- (NSArray *)allScenesForPlist;

@end
