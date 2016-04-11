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
        _editingQueue = dispatch_queue_create("com.BKR.editingQueue", DISPATCH_QUEUE_CONCURRENT);
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
        NSLog(@"BKREditor end of setEnabled block, before calling completion");
        if (editingBlock) {
            editingBlock(enabled, self->_currentCassette);
        }
        NSLog(@"BKREditor end of setEnabled block, after calling completion");
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

- (void)editCassetteSynchronously:(BKRCassetteEditingBlock)cassetteEditingBlock {
    if (!cassetteEditingBlock) {
        return;
    }
    BKRWeakify(self);
    dispatch_barrier_sync(self.editingQueue, ^{
        BKRStrongify(self);
        cassetteEditingBlock(self->_enabled, self->_currentCassette);
    });
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

- (void)readCassette:(BKRCassetteEditingBlock)cassetteEditingBlock {
    if (!cassetteEditingBlock) {
        return;
    }
    BKRWeakify(self);
    dispatch_sync(self.editingQueue, ^{
        BKRStrongify(self);
        cassetteEditingBlock(self->_enabled, self->_currentCassette);
    });
}

- (NSArray<BKRScene *> *)allScenes {
    return self.currentCassette.allScenes;
}

- (void)resetWithCompletionBlock:(void (^)(void))completionBlock {
    BKRWeakify(self);
    [self setEnabled:NO withCompletionHandler:^(BOOL updatedEnabled, BKRCassette *cassette) {
        BKRStrongify(self);
        self->_currentCassette = nil;
        if (completionBlock) {
            completionBlock();
        }
    }];
}

@end
