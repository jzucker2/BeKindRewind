//
//  BKRRecordableVCR.m
//  Pods
//
//  Created by Jordan Zucker on 2/9/16.
//
//

#import "BKRRecordableVCR.h"
#import "BKRConstants.h"
#import "BKRCassette+Recordable.h"
#import "BKRFilePathHelper.h"
#import "BKRRecorder.h"
#import "NSObject+BKRVCRAdditions.h"

@interface BKRRecordableVCR ()
@property (nonatomic) dispatch_queue_t accessQueue;
@end

@implementation BKRRecordableVCR

@synthesize state = _state;
@synthesize beginRecordingBlock = _beginRecordingBlock;
@synthesize endRecordingBlock = _endRecordingBlock;

- (instancetype)initWithEmptyCassetteSavingOption:(BOOL)shouldSaveEmptyCassette {
    self = [super init];
    if (self) {
        [[BKRRecorder sharedInstance] resetWithCompletionBlock:nil];
        _accessQueue = dispatch_queue_create("com.BKR.RecordableVCR", DISPATCH_QUEUE_CONCURRENT);
        _state = BKRVCRStateStopped;
        _shouldSaveEmptyCassette = shouldSaveEmptyCassette;
    }
    return self;
}

+ (instancetype)vcrWithEmptyCassetteSavingOption:(BOOL)shouldSaveEmptyCassette {
    return [[self alloc] initWithEmptyCassetteSavingOption:shouldSaveEmptyCassette];
}

+ (instancetype)vcr {
    return [self vcrWithEmptyCassetteSavingOption:NO];
}

#pragma mark - BKRVCRRecording

- (void)setBeginRecordingBlock:(BKRBeginRecordingTaskBlock)beginRecordingBlock {
    dispatch_barrier_async(self.accessQueue, ^{
        [BKRRecorder sharedInstance].beginRecordingBlock = beginRecordingBlock;
    });
}

- (BKRBeginRecordingTaskBlock)beginRecordingBlock {
    __block BKRBeginRecordingTaskBlock recordingBlock = nil;
    dispatch_sync(self.accessQueue, ^{
        recordingBlock = [BKRRecorder sharedInstance].beginRecordingBlock;
    });
    return recordingBlock;
}

- (void)setEndRecordingBlock:(BKREndRecordingTaskBlock)endRecordingBlock {
    dispatch_barrier_async(self.accessQueue, ^{
        [BKRRecorder sharedInstance].endRecordingBlock = endRecordingBlock;
    });
}

- (BKREndRecordingTaskBlock)endRecordingBlock {
    __block BKREndRecordingTaskBlock recordingBlock = nil;
    dispatch_sync(self.accessQueue, ^{
        recordingBlock = [BKRRecorder sharedInstance].endRecordingBlock;
    });
    return recordingBlock;
}

#pragma mark - BKRActions

- (BKRCassette *)currentCassette {
    __block BKRCassette *cassette = nil;
    dispatch_sync(self.accessQueue, ^{
        cassette = [BKRRecorder sharedInstance].currentCassette;
    });
    return cassette;
}

- (void)playWithCompletionBlock:(void (^)(void))completionBlock {
    // no-op
    NSLog(@"recording VCR can't play a cassette");
}

- (void)recordWithCompletionBlock:(void (^)(void))completionBlock {
    BKRWeakify(self);
    dispatch_barrier_async(self.accessQueue, ^{
        BKRStrongify(self);
        switch (self->_state) {
            case BKRVCRStatePlaying:
            case BKRVCRStateUnknown:
                NSLog(@"How did we get here?");
                break;
            case BKRVCRStateRecording:
                break;
            case BKRVCRStatePaused:
            case BKRVCRStateStopped:
            {
                self->_state = BKRVCRStateRecording;
                [[BKRRecorder sharedInstance] setEnabled:YES withCompletionHandler:completionBlock];
            }
                break;
        }
    });
}

- (BOOL)insert:(BKRVCRCassetteLoadingBlock)cassetteLoadingBlock completionHandler:(BKRCassetteHandlingBlock)completionBlock {
    // can't insert a cassette if you already have one
    if (self.currentCassette) {
        NSLog(@"Already contains a cassette");
        [self BKR_executeCassetteHandlingBlockWithFinalResult:NO onMainQueue:completionBlock];
        return NO;
    }
    __block BOOL finalResult = NO;
    dispatch_barrier_sync(self.accessQueue, ^{
        if (!cassetteLoadingBlock) {
            finalResult = NO;
            return;
        }
        BKRCassette *loadingCassette = cassetteLoadingBlock();
        NSLog(@"loading cassette: %@", loadingCassette);
        // if no cassette dictionary is fetched, then return NO
        finalResult = (loadingCassette ? YES : NO);
        [BKRRecorder sharedInstance].currentCassette = loadingCassette;
    });
    [self BKR_executeCassetteHandlingBlockWithFinalResult:finalResult onMainQueue:completionBlock];
    return finalResult;
}

- (BOOL)eject:(BKRVCRCassetteSavingBlock)cassetteSavingBlock completionHandler:(BKRCassetteHandlingBlock)completionBlock {
    if (!self.currentCassette) {
        NSLog(@"no cassette contained");
        [self BKR_executeCassetteHandlingBlockWithFinalResult:NO onMainQueue:completionBlock];
        return NO;
    }
    __block BOOL finalResult = NO;
    __block NSString *finalPath = nil;
    [self stopWithCompletionBlock:nil]; // call a stop, no completion necessary, not done yet
    BKRWeakify(self);
    BKRCassette *lastCassette = self.currentCassette;
    dispatch_barrier_sync(self.accessQueue, ^{
        BKRStrongify(self);
        // if current VCR state is unknown, then let's log an error and stop
        if (self->_state == BKRVCRStateUnknown) {
            NSLog(@"what happened, how did we get in this state? Please open a GitHub issue");
            return;
        }
        // if there's nothing to record and we aren't supposed to save empty cassettes, then exit here
        if (
            (!self->_shouldSaveEmptyCassette) &&
            (![BKRRecorder sharedInstance].didRecord)
            ) {
            [[BKRRecorder sharedInstance] resetWithCompletionBlock:nil];
            return;
        }
        // if there's no lastCassette or saving block then stop
        if (!lastCassette) {
            NSLog(@"There's no cassette in the vcr");
            finalResult = NO;
            return;
        }
        if (!cassetteSavingBlock) {
            NSLog(@"There's no cassette saving block");
            finalResult = NO;
            return;
        }
        NSString *currentFilePath = cassetteSavingBlock(lastCassette);
        if (!currentFilePath) {
            NSLog(@"There is no path to save file at");
            finalResult = NO;
            return;
        }
        NSDictionary *cassetteDictionary = [BKRRecorder sharedInstance].plistDictionary;
        finalPath = currentFilePath;
        NSLog(@"trying to write cassette to: %@", currentFilePath);
        finalResult = [BKRFilePathHelper writeDictionary:cassetteDictionary toFile:currentFilePath];
        self->_state = BKRVCRStateStopped; // somewhat unnecessary
        [[BKRRecorder sharedInstance] resetWithCompletionBlock:nil]; // reset the recorder (removes cassette)
    });
    [self BKR_executeCassetteHandlingBlockWithFinalResult:finalResult onMainQueue:completionBlock];
    return finalResult;
}

- (void)stopWithCompletionBlock:(void (^)(void))completionBlock {
    BKRWeakify(self);
    dispatch_barrier_async(self.accessQueue, ^{
        BKRStrongify(self);
        switch (self->_state) {
            case BKRVCRStatePlaying:
            case BKRVCRStateUnknown:
                NSLog(@"How did we get here?");
                break;
            case BKRVCRStatePaused:
            case BKRVCRStateRecording:
            {
                self->_state = BKRVCRStateStopped;
                [[BKRRecorder sharedInstance] setEnabled:NO withCompletionHandler:completionBlock];
            }
                break;
            case BKRVCRStateStopped:
                break;
        }
    });
}

- (void)pauseWithCompletionBlock:(void (^)(void))completionBlock {
    BKRWeakify(self);
    dispatch_barrier_async(self.accessQueue, ^{
        BKRStrongify(self);
        switch (self->_state) {
            case BKRVCRStatePlaying:
            case BKRVCRStateUnknown:
                NSLog(@"How did we get here?");
                break;
            case BKRVCRStateRecording:
            {
                self->_state = BKRVCRStatePaused;
                [[BKRRecorder sharedInstance] setEnabled:NO withCompletionHandler:completionBlock];
            }
                break;
            case BKRVCRStatePaused:
            case BKRVCRStateStopped:
                break;
        }
    });
}

- (void)resetWithCompletionBlock:(void (^)(void))completionBlock {
    BKRWeakify(self);
    dispatch_barrier_async(self.accessQueue, ^{
        BKRStrongify(self);
//        self->_cassetteFilePath = nil;
        self->_state = BKRVCRStateStopped;
        [[BKRRecorder sharedInstance] resetWithCompletionBlock:completionBlock];
    });
}

- (BKRVCRState)state {
    __block BKRVCRState currentState;
    BKRWeakify(self);
    dispatch_sync(self.accessQueue, ^{
        BKRStrongify(self);
        currentState = self->_state;
    });
    return currentState;
}

@end
