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
#import "BKRFilePathHelper.h"
#import "BKRRecordableCassette.h"
#import "BKRPlayableCassette.h"

@interface BKRVCR ()
@property (nonatomic, strong) BKRPlayer *player;
@property (nonatomic) dispatch_queue_t processingQueue;
@property (nonatomic, strong, readwrite) BKRCassette *currentCassette;
@property (nonatomic, assign, readwrite) BKRVCRState state;
@property (nonatomic, copy, readwrite) NSString *cassetteFilePath;
@end

@implementation BKRVCR
@synthesize currentCassette = _currentCassette;
@synthesize state = _state;

- (instancetype)initWithMatcherClass:(Class<BKRRequestMatching>)matcherClass {
    self = [super init];
    if (self) {
        _player = [BKRPlayer playerWithMatcherClass:matcherClass];
        [BKRRecorder sharedInstance].enabled = NO;
        _processingQueue = dispatch_queue_create("com.BKR.VCR.processingQueue", DISPATCH_QUEUE_CONCURRENT);
//        _disabled = NO;
//        _recording = NO;
    }
    return self;
}

+ (instancetype)vcrWithMatcherClass:(Class<BKRRequestMatching>)matcherClass {
    return [[self alloc] initWithMatcherClass:matcherClass];
}

- (id<BKRRequestMatching>)matcher {
    return self.player.matcher;
}

//- (void)setDisabled:(BOOL)disabled {
//    __weak typeof(self) wself = self;
//    dispatch_barrier_async(self.processingQueue, ^{
//        __strong typeof(wself) sself = wself;
//        sself->_disabled = disabled;
//    });
//}
//
//- (BOOL)isDisabled {
//    __block BOOL currentDisabled;
//    __weak typeof(self) wself = self;
//    dispatch_sync(self.processingQueue, ^{
//        __strong typeof(wself) sself = wself;
//        currentDisabled = sself->_disabled;
//    });
//    return currentDisabled;
//}

//- (void)setRecording:(BOOL)recording {
//    __weak typeof(self) wself = self;
//    dispatch_barrier_async(self.processingQueue, ^{
//        __strong typeof(wself) sself = wself;
//        sself->_recording = recording;
//    });
//}
//
//- (BOOL)isRecording {
//    __block BOOL currentRecording;
//    __weak typeof(self) wself = self;
//    dispatch_sync(self.processingQueue, ^{
//        __strong typeof(wself) sself = wself;
//        currentRecording = sself->_recording;
//    });
//    return currentRecording;
//}

//- (void)setCurrentCassette:(BKRCassette *)currentCassette {
//    __weak typeof(self) wself = self;
//    dispatch_barrier_async(self.processingQueue, ^{
//        __strong typeof(wself) sself = wself;
//        sself->_currentCassette = currentCassette;
//    });
//}
//
//- (BKRCassette *)currentCassette {
//    __block BKRCassette *cassette;
//    __weak typeof(self) wself = self;
//    dispatch_sync(self.processingQueue, ^{
//        __strong typeof(wself) sself = wself;
//        cassette = sself->_currentCassette;
//    });
//    return cassette;
//}

#pragma mark - BKRVCRActions overrides

- (void)setCassetteFilePath:(NSString *)cassetteFilePath {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        sself->_cassetteFilePath = cassetteFilePath;
    });
}

#pragma mark - BKRVCRActions

//- (void)setCurrentCassette:(BKRCassette *)currentCassette {
//    __weak typeof(self) wself = self;
//    dispatch_barrier_async(self.processingQueue, ^{
//        __strong typeof(wself) sself = wself;
//        sself->_currentCassette = currentCassette;
//    });
//}

//// this depends on state, whether it returns a playable cassette or a recording cassette
//- (BKRCassette *)currentCassette {
//    __block BKRCassette *cassette;
//    __weak typeof(self) wself = self;
//    dispatch_sync(self.processingQueue, ^{
//        __strong typeof(wself) sself = wself;
//        cassette = (BKRCassette *)sself.player.currentCassette;
//    });
//    return cassette;
//}

- (void)play {
    __weak typeof(self) wself = self;
    NSString *currentCassettePath = self.cassetteFilePath;
    dispatch_barrier_async(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        [BKRRecorder sharedInstance].enabled = NO;
        NSDictionary *playableCassetteDictionary = [BKRFilePathHelper dictionaryForPlistFilePath:currentCassettePath];
        sself.player.currentCassette = [BKRPlayableCassette cassetteFromDictionary:playableCassetteDictionary];
        sself.player.enabled = YES;
        sself->_state = BKRVCRStatePlaying;
    });
}

- (void)pause {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        [BKRRecorder sharedInstance].enabled = NO;
        sself.player.enabled = NO;
        sself->_state = BKRVCRStatePaused;
    });
}

- (void)stop {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        [BKRRecorder sharedInstance].enabled = NO;
        sself.player.enabled = NO;
        sself->_state = BKRVCRStateStopped;
    });
}

- (void)reset {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        [BKRRecorder sharedInstance].enabled = NO;
        [[BKRRecorder sharedInstance] reset];
        sself.player.enabled = NO;
        [sself.player reset];
        sself->_state = BKRVCRStateStopped;
    });
}

- (void)insert:(NSString *)cassetteFilePath {
    NSParameterAssert(cassetteFilePath);
//    NSParameterAssert([[NSFileManager defaultManager] fileExistsAtPath:cassetteFilePath]);
//    [BKRFilePathHelper filePathExists:cassetteFilePath];
    self.cassetteFilePath = cassetteFilePath;
}

- (BOOL)eject:(BOOL)shouldOverwrite {
    // don't save if you don't record
    if (![BKRRecorder sharedInstance].didRecord) {
        // didn't save anything, so return NO
        return NO;
    }
    NSString *currentCassetteFilePath = self.cassetteFilePath;
    if (!currentCassetteFilePath) {
        NSLog(@"There is no cassette file path provided, so nothing can be saved");
        return NO;
    }
    if (
        [BKRFilePathHelper filePathExists:currentCassetteFilePath] &&
        !shouldOverwrite
        ) {
        NSLog(@"File already exists at that path and shouldOverwrite was set NO, so no save occurs");
        return NO;
    }
    BKRRecordableCassette *cassette = (BKRRecordableCassette *)self.currentCassette;
    return [BKRFilePathHelper writeDictionary:cassette.plistDictionary toFile:currentCassetteFilePath];
}

- (void)record {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        sself.player.enabled = NO;
        BKRRecordableCassette *cassette = [BKRRecordableCassette cassette];
        [BKRRecorder sharedInstance].currentCassette = cassette;
        [BKRRecorder sharedInstance].enabled = YES;
        sself->_state = BKRVCRStateRecording;
    });
}

- (BKRVCRState)state {
    __block BKRVCRState currentState;
    __weak typeof(self) wself = self;
    dispatch_sync(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        currentState = sself->_state;
    });
    return currentState;
}

//- (void)setState:(BKRVCRState)state {
//    __weak typeof(self) wself = self;
//    dispatch_barrier_async(self.processingQueue, ^{
//        __strong typeof(wself) sself = wself;
//        sself->_state = state;
//    });
//}

@end
