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

/**
 *  Thread-safe block to process editor actions with enabled state
 *  and casseette when the block is being executed.
 *
 *  @param updatedEnabled current enabled state of editor
 *  @param cassette       current cassette when block is being processed.
 */
typedef void (^BKRCassetteEditingBlock)(BOOL updatedEnabled, BKRCassette *cassette);

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

/**
 *  This is an asynchronous, thead-safe option to toggle enabled on the receiver with a completion
 *  block. Helpful for using in testing.
 *
 *  @param enabled      this determines whether the editor is enabled or disabled.
 *  @param editingBlock this is called on the receiver's queue
 */
- (void)setEnabled:(BOOL)enabled withCompletionHandler:(BKRCassetteEditingBlock)editingBlock;

/**
 *  This is a thread-safe, asynchronous, non-blocking method to edit the cassette contained inside
 *  the editor instance
 *
 *  @param cassetteEditingBlock this is called on the receiver's queue
 */
- (void)editCassette:(BKRCassetteEditingBlock)cassetteEditingBlock;

/**
 *  This is a thread-safe, synchronous, blocking method to edit the cassette contained inside
 *  the editor instance. This blocks on the queue that it is called in
 *
 *  @param cassetteEditingBlock this is called on the receiver's queue
 */
- (void)editCassetteSynchronously:(BKRCassetteEditingBlock)cassetteEditingBlock;

// synchronous and blocking, thread-safe, dispatch_sync
- (void)readCassette:(BKRCassetteEditingBlock)cassetteEditingBlock;

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

/**
 *  Resets the receiver if it contains any internal state. This should
 *  usually be called at the end of a session. This method is non-blocking
 *  and asynchronously called on the receiver's internal custom queue. This
 *  method sets the receiver's enabled property to NO
 *
 *  @param completionBlock run on the receiver's queue after the reset 
 *                         actions are performed
 */
- (void)resetWithCompletionBlock:(void(^)(void))completionBlock;

@end
