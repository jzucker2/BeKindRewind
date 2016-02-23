//
//  BKREditor.m
//  Pods
//
//  Created by Jordan Zucker on 1/28/16.
//
//

#import "BKREditor.h"
#import "BKRCassette.h"
#import "BKRScene.h"
#import "BKRConstants.h"

@implementation BKREditor

@synthesize enabled = _enabled;
@synthesize currentCassette = _currentCassette;

- (instancetype)init {
    self = [super init];
    if (self) {
        _enabled = NO;
        _editingQueue = dispatch_queue_create("com.BKR.CassetteHandler", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

+ (instancetype)editor {
    return [[self alloc] init];
}

- (void)setEnabled:(BOOL)enabled withCompletionHandler:(BKRCassetteEditingBlock)editingBlock {
    BKRWeakify(self);
    dispatch_barrier_async(self.editingQueue, ^{
        BKRStrongify(self);
        self->_enabled = enabled;
        if (editingBlock) {
            editingBlock(enabled, self->_currentCassette);
        }
    });
}

- (void)editCassette:(BKRCassetteEditingBlock)cassetteEditingBlock {
    if (!cassetteEditingBlock) {
        return;
    }
    BKRWeakify(self);
    dispatch_barrier_async(self.editingQueue, ^{
        BKRStrongify(self);
        cassetteEditingBlock(self->_enabled, self->_currentCassette);
    });
}

#warning this seems not actually synchronous, test or add a second block to be synch?
- (void)editCassetteSynchronously:(BKRCassetteEditingBlock)cassetteEditingBlock {
    if (!cassetteEditingBlock) {
        return;
    }
    BKRWeakify(self);
    NSLog(@"%@ (editSynchronously): before barrier sync", self);
    dispatch_barrier_sync(self.editingQueue, ^{
        BKRStrongify(self);
        NSLog(@"%@ (editSynchronously): start barrier sync", self);
        cassetteEditingBlock(self->_enabled, self->_currentCassette);
        NSLog(@"%@ (editSynchronously): end of barrier sync", self);
    });
    NSLog(@"%@ (editSynchronously): after barrier sync", self);
}

- (void)setEnabled:(BOOL)enabled {
    [self setEnabled:enabled withCompletionHandler:nil];
}

- (BOOL)isEnabled {
    __block BOOL currentEnabled;
    BKRWeakify(self);
    dispatch_sync(self.editingQueue, ^{
        BKRStrongify(self);
        currentEnabled = self->_enabled;
    });
    return currentEnabled;
}

- (void)setCurrentCassette:(BKRCassette *)currentCassette {
    BKRWeakify(self);
    dispatch_barrier_async(self.editingQueue, ^{
        BKRStrongify(self);
        self->_currentCassette = currentCassette;
    });
}

- (BKRCassette *)currentCassette {
    __block BKRCassette *cassette = nil;
    BKRWeakify(self);
    dispatch_sync(self.editingQueue, ^{
        BKRStrongify(self);
        cassette = self->_currentCassette;
    });
    return cassette;
}

- (NSArray<BKRScene *> *)allScenes {
    return self.currentCassette.allScenes;
}

@end
