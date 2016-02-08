//
//  BKRVCR.m
//  Pods
//
//  Created by Jordan Zucker on 1/19/16.
//
//

#import "BKRVCR.h"
#import "BKRCassette.h"
#import "BKRRecorder.h"
#import "BKRPlayer.h"

@interface BKRVCR ()
@property (nonatomic, strong) BKRPlayer *player;
@property (nonatomic) dispatch_queue_t processingQueue;
@end

@implementation BKRVCR
@synthesize recording = _recording;
@synthesize disabled = _disabled;
@synthesize currentCassette = _currentCassette;

- (instancetype)initWithMatcherClass:(Class<BKRRequestMatching>)matcherClass {
    self = [super init];
    if (self) {
        _player = [BKRPlayer playerWithMatcherClass:matcherClass];
        [BKRRecorder sharedInstance].enabled = NO;
        _processingQueue = dispatch_queue_create("com.BKR.VCR.processingQueue", DISPATCH_QUEUE_CONCURRENT);
        _disabled = NO;
        _recording = NO;
    }
    return self;
}

+ (instancetype)vcrWithMatcherClass:(Class<BKRRequestMatching>)matcherClass {
    return [[self alloc] initWithMatcherClass:matcherClass];
}

- (id<BKRRequestMatching>)matcher {
    return self.player.matcher;
}

- (void)setDisabled:(BOOL)disabled {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        sself->_disabled = disabled;
    });
}

- (BOOL)isDisabled {
    __block BOOL currentDisabled;
    __weak typeof(self) wself = self;
    dispatch_sync(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        currentDisabled = sself->_disabled;
    });
    return currentDisabled;
}

- (void)setRecording:(BOOL)recording {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        sself->_recording = recording;
    });
}

- (BOOL)isRecording {
    __block BOOL currentRecording;
    __weak typeof(self) wself = self;
    dispatch_sync(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        currentRecording = sself->_recording;
    });
    return currentRecording;
}

- (void)setCurrentCassette:(BKRCassette *)currentCassette {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        sself->_currentCassette = currentCassette;
    });
}

- (BKRCassette *)currentCassette {
    __block BKRCassette *cassette;
    __weak typeof(self) wself = self;
    dispatch_sync(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        cassette = sself->_currentCassette;
    });
    return cassette;
}

@end
