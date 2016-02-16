//
//  BKREditor.h
//  Pods
//
//  Created by Jordan Zucker on 1/28/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRConstants.h"

@class BKRCassette;
@class BKRScene;

/**
 *  This object is responsible for translating BeKindRewind network information between cassettes
 *  and network objects
 */
@interface BKREditor : NSObject

/**
 *  Convenience initializer
 *
 *  @return instance of BKREditor
 */
+ (instancetype)editor;

/**
 *  Determines whether editor should be executing
 */
@property (nonatomic, getter=isEnabled) BOOL enabled;

- (void)setEnabled:(BOOL)enabled withCompletionHandler:(BKRCassetteEditingBlock)editingBlock;
- (void)editCassette:(BKRCassetteEditingBlock)cassetteEditingBlock;
- (void)editCassetteSynchronously:(BKRCassetteEditingBlock)cassetteEditingBlock;

/**
 *  Separate queue for processing editing actions
 */
@property (nonatomic) dispatch_queue_t editingQueue;

/**
 *  Cassette to perform editing actions on, editing will not occur if cassette is nil
 */
@property (nonatomic, strong) BKRCassette *currentCassette;

/**
 *  All scenes from cassette in order of creation
 *
 *  @return array of ordered scenes
 */
- (NSArray<BKRScene *> *)allScenes;

@end
