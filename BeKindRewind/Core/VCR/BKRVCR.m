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
@synthesize afterAddingStubsBlock = _afterAddingStubsBlock;
@synthesize beforeAddingStubsBlock = _beforeAddingStubsBlock;
@synthesize beginRecordingBlock = _beginRecordingBlock;
@synthesize endRecordingBlock = _endRecordingBlock;

- (instancetype)initWithMatcherClass:(Class<BKRRequestMatching>)matcherClass {
    self = [super init];
    if (self) {
        _player = [BKRPlayer playerWithMatcherClass:matcherClass];
        [BKRRecorder sharedInstance].enabled = NO;
        _processingQueue = dispatch_queue_create("com.BKR.VCR.processingQueue", DISPATCH_QUEUE_CONCURRENT);
        _state = BKRVCRStateStopped;
        _currentCassette = nil;
        _cassetteFilePath = nil;
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

#pragma mark - BKRVCR Helper

- (void)_logVCRStateUnknown {
    NSLog(@"How did we end up here? Create an issue please with logs");
}

// if cassetteFilePath is nil then this is nil
- (BKRCassette *)_cassetteForVCRState {
    NSString *casetteFilePath = self->_cassetteFilePath;
    BKRCassette *cassette = self->_currentCassette;
    if (!casetteFilePath) {
        return nil;
    }
    switch (self->_state) {
        case BKRVCRStateUnknown:
        {
            [self _logVCRStateUnknown];
            return nil;
        }
            break;
        case BKRVCRStatePaused:
        {
            
        }
            break;
        case BKRVCRStateStopped:
        {
            
        }
            break;
        case BKRVCRStatePlaying:
        {
            
        }
            break;
        case BKRVCRStateRecording:
        {
            
        }
            break;
    }
}

#pragma mark - BKRVCRActions overrides

- (void)setCassetteFilePath:(NSString *)cassetteFilePath {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        NSString *oldCassetteFilePath = sself->_cassetteFilePath;
        sself->_cassetteFilePath = cassetteFilePath;
        // make sure to get rid of current cassette if the cassette file path changes
        if (oldCassetteFilePath != cassetteFilePath) {
            sself->_currentCassette = nil;
        }
    });
}

// thread safe
- (BKRPlayableCassette *)_createPlayableCassette {
    NSDictionary *cassetteDictionary = [BKRFilePathHelper dictionaryForPlistFilePath:self->_cassetteFilePath];
    return [BKRPlayableCassette cassetteFromDictionary:cassetteDictionary];
}

// thread safe
- (BKRRecordableCassette *)_createRecordableCassette {
    return [BKRRecordableCassette cassette];
}

#pragma mark - BKRVCRActions

//- (void)setCurrentCassette:(BKRCassette *)currentCassette {
//    __weak typeof(self) wself = self;
//    dispatch_barrier_async(self.processingQueue, ^{
//        __strong typeof(wself) sself = wself;
//        sself->_currentCassette = currentCassette;
//    });
//}

- (void)setAfterAddingStubsBlock:(BKRAfterAddingStubs)afterAddingStubsBlock {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        sself->_afterAddingStubsBlock = afterAddingStubsBlock;
    });
}

- (BKRAfterAddingStubs)afterAddingStubsBlock {
    __block BKRAfterAddingStubs block;
    __weak typeof(self) wself = self;
    dispatch_sync(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        block = sself->_afterAddingStubsBlock;
    });
    return block;
}

- (void)setBeforeAddingStubsBlock:(BKRBeforeAddingStubs)beforeAddingStubsBlock {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        sself->_beforeAddingStubsBlock = beforeAddingStubsBlock;
    });
}

- (BKRBeforeAddingStubs)beforeAddingStubsBlock {
    __block BKRBeforeAddingStubs block;
    __weak typeof(self) wself = self;
    dispatch_sync(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        block = sself->_beforeAddingStubsBlock;
    });
    return block;
}

- (void)setBeginRecordingBlock:(BKRBeginRecordingTaskBlock)beginRecordingBlock {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        sself->_beginRecordingBlock = beginRecordingBlock;
    });
}

- (BKRBeginRecordingTaskBlock)beginRecordingBlock {
    __block BKRBeginRecordingTaskBlock block;
    __weak typeof(self) wself = self;
    dispatch_sync(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        block = sself->_beginRecordingBlock;
    });
    return block;
}

- (void)setEndRecordingBlock:(BKREndRecordingTaskBlock)endRecordingBlock {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        sself->_endRecordingBlock = endRecordingBlock;
    });
}

- (BKREndRecordingTaskBlock)endRecordingBlock {
    __block BKREndRecordingTaskBlock block;
    __weak typeof(self) wself = self;
    dispatch_sync(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        block = sself->_endRecordingBlock;
    });
    return block;
}

//// this depends on state, whether it returns a playable cassette or a recording cassette
- (BKRCassette *)currentCassette {
    __block BKRCassette *cassette;
    __weak typeof(self) wself = self;
    dispatch_sync(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        cassette = sself->_currentCassette;
    });
    return cassette;
}

- (void)play {
    __weak typeof(self) wself = self;
//    NSString *currentCassettePath = self.cassetteFilePath;
    dispatch_barrier_async(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        // don't bother if already playing
        switch (sself->_state) {
            case BKRVCRStateUnknown:
            {
                [self _logVCRStateUnknown];
                return;
            }
                break;
            case BKRVCRStateRecording:
            {
                NSLog(@"can't switch to playing if recording, send a `stop` or `eject:` command first");
                return;
            }
                break;
            case BKRVCRStatePlaying:
                break;
            case BKRVCRStatePaused:
            case BKRVCRStateStopped:
            {
                
            }
                break;
        }
        sself->_state = BKRVCRStatePlaying;
//        [BKRRecorder sharedInstance].enabled = NO;
//        NSDictionary *playableCassetteDictionary = [BKRFilePathHelper dictionaryForPlistFilePath:currentCassettePath];
//        sself.player.currentCassette = [BKRPlayableCassette cassetteFromDictionary:playableCassetteDictionary];
//        sself.player.enabled = YES;
//        sself->_state = BKRVCRStatePlaying;
    });
}

- (void)pause {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        switch (sself->_state) {
            case BKRVCRStateUnknown:
                [self _logVCRStateUnknown];
                break;
            case BKRVCRStatePaused:
            case BKRVCRStateStopped:
                break;
            case BKRVCRStatePlaying:
            case BKRVCRStateRecording:
            {
                
            }
                break;
        }
        sself->_state = BKRVCRStatePaused;
//        [BKRRecorder sharedInstance].enabled = NO;
//        sself.player.enabled = NO;
//        sself->_state = BKRVCRStatePaused;
    });
}

- (void)stop {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        switch (sself->_state) {
            case BKRVCRStateUnknown:
            {
                [self _logVCRStateUnknown];
                return;
            }
            case BKRVCRStatePaused:
            case BKRVCRStateStopped:
                break;
            case BKRVCRStateRecording:
            {
                
            }
                break;
            case BKRVCRStatePlaying:
            {
                
            }
                break;
        }
        sself->_state = BKRVCRStateStopped;
//        [BKRRecorder sharedInstance].enabled = NO;
//        sself.player.enabled = NO;
//        sself->_state = BKRVCRStateStopped;
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
        sself->_cassetteFilePath = nil;
        sself->_currentCassette = nil;
        sself->_state = BKRVCRStateStopped;
    });
}

- (BOOL)insert:(NSString *)cassetteFilePath {
    NSParameterAssert(cassetteFilePath);
    if (self.currentCassette) {
        NSLog(@"already contains a cassette, must eject or reset first");
        return NO;
    }
    // If state is a postive integer than the tape cannot be replaced at this time
    if (self.state > 0) {
        NSLog(@"cannot insert a tape unless BKRVCR is in state BKRVCRStateStopped. Consider calling `stop` or `reset` before trying to insert a new tape");
        return NO;
    }
    self.cassetteFilePath = cassetteFilePath;
    return YES;
}

- (BOOL)eject:(BOOL)shouldOverwrite {
    __block NSString *currentCassetteFilePath;
    __block BKRVCRState currentState;
    __block BKRCassette *cassette;
    
    BOOL finalReturnValue = NO;
    NSString *updatedCassetteFilePath = nil;
    BKRCassette *finalCassette = nil;
    __weak typeof(self) wself = self;
    dispatch_sync(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        currentCassetteFilePath = sself->_cassetteFilePath;
        cassette = sself->_currentCassette;
        currentState = sself->_state;
    });
    if (!currentCassetteFilePath) {
        NSLog(@"There is no cassette file path provided, so nothing can be saved");
        return NO;
    }
    // don't save if you don't record
    if (![BKRRecorder sharedInstance].didRecord) {
        // didn't save anything, so return NO
        NSLog(@"The cassetteFilePath will be removed but nothing was recorded, so nothing will be saved, or created");
        self.currentCassette = nil;
        return NO;
    }
    if (
        [BKRFilePathHelper filePathExists:currentCassetteFilePath] &&
        !shouldOverwrite
        ) {
        NSLog(@"File already exists at that path and shouldOverwrite was set NO, so no save occurs");
        self.currentCassette = nil;
        return NO;
    }
//    BKRRecordableCassette *cassette = (BKRRecordableCassette *)self.currentCassette;
//    self.currentCassette = nil;
    
    
    
//    return [BKRFilePathHelper writeDictionary:cassette.plistDictionary toFile:currentCassetteFilePath];
    
    dispatch_barrier_async(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        sself->_state = BKRVCRStateStopped;
        sself->_cassetteFilePath = nil;
        sself->_currentCassette = nil;
    });
    
    return YES;
}

- (void)record {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        sself.player.enabled = NO;
//        BKRRecordableCassette *cassette = [BKRRecordableCassette cassette];
//        [BKRRecorder sharedInstance].currentCassette = cassette;
//        [BKRRecorder sharedInstance].enabled = YES;
//        sself->_state = BKRVCRStateRecording;
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
