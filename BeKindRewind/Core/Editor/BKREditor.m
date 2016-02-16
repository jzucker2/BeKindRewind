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
//    BKRWeakify(self);
//    dispatch_barrier_async(self.editingQueue, ^{
//        BKRStrongify(self);
//        self->_enabled = enabled;
//        if (completionBlock) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                completionBlock();
//            });
//        }
//    });
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

- (void)setEnabled:(BOOL)enabled {
    [self setEnabled:enabled withCompletionHandler:nil];
}

- (BOOL)isEnabled {
    __block BOOL currentEnabled;
    __weak typeof(self) wself = self;
    dispatch_sync(self.editingQueue, ^{
        __strong typeof(wself) sself = wself;
        currentEnabled = sself->_enabled;
    });
    return currentEnabled;
}

- (void)setCurrentCassette:(BKRCassette *)currentCassette {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.editingQueue, ^{
        __strong typeof(wself) sself = wself;
        sself->_currentCassette = currentCassette;
    });
}

- (BKRCassette *)currentCassette {
    __block BKRCassette *cassette = nil;
    __weak typeof(self) wself = self;
    dispatch_sync(self.editingQueue, ^{
        __strong typeof(wself) sself = wself;
        cassette = sself->_currentCassette;
    });
    return cassette;
}

- (NSArray<BKRScene *> *)allScenes {
    return self.currentCassette.allScenes;
}

@end
