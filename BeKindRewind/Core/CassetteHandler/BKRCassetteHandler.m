//
//  BKRCassetteHandler.m
//  Pods
//
//  Created by Jordan Zucker on 1/28/16.
//
//

#import "BKRCassetteHandler.h"
#import "BKRCassette.h"
#import "BKRScene.h"

@interface BKRCassetteHandler ()

@end

@implementation BKRCassetteHandler

@synthesize enabled = _enabled;
@synthesize currentCassette = _currentCassette;

- (instancetype)init {
    self = [super init];
    if (self) {
        _enabled = NO;
        _processingQueue = dispatch_queue_create("com.BKR.CassetteHandler", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

+ (instancetype)handler {
    return [[self alloc] init];
}

- (void)setEnabled:(BOOL)enabled {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        sself->_enabled = enabled;
    });
}

- (BOOL)isEnabled {
    __block BOOL currentEnabled;
    __weak typeof(self) wself = self;
    dispatch_sync(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        currentEnabled = sself->_enabled;
    });
    return currentEnabled;
}

- (void)setCurrentCassette:(BKRCassette *)currentCassette {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        sself->_currentCassette = currentCassette;
    });
}

- (BKRCassette *)currentCassette {
    __block BKRCassette *cassette = nil;
    __weak typeof(self) wself = self;
    dispatch_sync(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        cassette = sself->_currentCassette;
    });
    return cassette;
}

- (NSArray<BKRScene *> *)allScenes {
    return self.currentCassette.allScenes;
}

@end
