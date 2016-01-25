//
//  BKRPlayer.h
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRRequestMatching.h"

@class BKRPlayableCassette;
@class BKRPlayableScene;

@interface BKRPlayer : NSObject

/**
 *  Whether or not network activity should be recorded
 */
@property (nonatomic, getter=isEnabled) BOOL enabled;

@property (nonatomic, strong) BKRPlayableCassette *currentCassette;

@property (nonatomic, strong) id<BKRRequestMatching>matcher;

- (BKRPlayableScene *)playhead;

- (void)reset;

@end
