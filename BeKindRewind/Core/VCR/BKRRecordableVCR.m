//
//  BKRRecordableVCR.m
//  Pods
//
//  Created by Jordan Zucker on 2/9/16.
//
//

#import "BKRRecordableVCR.h"
#import "BKRConstants.h"
#import "BKRConfiguration.h"
#import "BKRCassette+Recordable.h"
#import "BKRFilePathHelper.h"
#import "BKRRecorder.h"
#import "NSObject+BKRVCRAdditions.h"

@interface BKRRecordableVCR ()
@property (nonatomic) dispatch_queue_t accessQueue;
@property (nonatomic, copy) BKRConfiguration *configuration;
@end

@implementation BKRRecordableVCR

@synthesize state = _state;

- (instancetype)initWithConfiguration:(BKRConfiguration *)configuration {
    self = [super init];
    if (self) {
        [[BKRRecorder sharedInstance] resetWithCompletionBlock:nil];
        _accessQueue = dispatch_queue_create("com.BKR.RecordableVCR", DISPATCH_QUEUE_CONCURRENT);
        _state = BKRVCRStateStopped;
        _configuration = configuration.copy;
        [BKRRecorder sharedInstance].beginRecordingBlock = _configuration.beginRecordingBlock;
        [BKRRecorder sharedInstance].endRecordingBlock = _configuration.endRecordingBlock;
    }
    return self;
}

+ (instancetype)vcrWithConfiguration:(BKRConfiguration *)configuration {
    return [[self alloc] initWithConfiguration:configuration];
}

+ (instancetype)defaultVCR {
    return [self vcrWithConfiguration:[BKRConfiguration defaultConfiguration]];
}

#pragma mark - BKRActions

- (BKRConfiguration *)currentConfiguration {
    return self.configuration.copy;
}

- (BKRCassette *)currentCassette {
    __block BKRCassette *cassette = nil;
    dispatch_sync(self.accessQueue, ^{
        cassette = [BKRRecorder sharedInstance].currentCassette;
    });
    return cassette;
}

- (void)playWithCompletionBlock:(BKRVCRActionCompletionBlock)completionBlock {
    NSLog(@"recording VCR can't play a cassette");
    if (!completionBlock) {
        return;
    }
    dispatch_barrier_async(self.accessQueue, ^{
        completionBlock(NO);
    });
}

- (void)recordWithCompletionBlock:(BKRVCRActionCompletionBlock)completionBlock {
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
                [[BKRRecorder sharedInstance] setEnabled:YES withCompletionHandler:^{
                    if (completionBlock) {
                        completionBlock(YES);
                    }
                }];
                return;
            }
                break;
        }
        if (completionBlock) {
            completionBlock(NO);
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
        // if no cassette dictionary is fetched, then return NO
        finalResult = (loadingCassette ? YES : NO);
        [BKRRecorder sharedInstance].currentCassette = loadingCassette;
    });
    [self BKR_executeCassetteHandlingBlockWithFinalResult:finalResult onMainQueue:completionBlock];
    return finalResult;
}

- (BOOL)eject:(BKRVCRCassetteSavingBlock)cassetteSavingBlock completionHandler:(BKRCassetteHandlingBlock)completionBlock {
    if (!self.currentCassette) {
        NSLog(@"%@ no cassette contained", self);
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
            (!self->_configuration.shouldSaveEmptyCassette) &&
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
        NSLog(@"%@: trying to write cassette to: %@", self, currentFilePath);
        finalResult = [BKRFilePathHelper writeDictionary:cassetteDictionary toFile:currentFilePath];
        self->_state = BKRVCRStateStopped; // somewhat unnecessary
        [[BKRRecorder sharedInstance] resetWithCompletionBlock:nil]; // reset the recorder (removes cassette)
    });
    [self BKR_executeCassetteHandlingBlockWithFinalResult:finalResult onMainQueue:completionBlock];
    return finalResult;
}

- (void)stopWithCompletionBlock:(BKRVCRActionCompletionBlock)completionBlock {
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
                [[BKRRecorder sharedInstance] setEnabled:NO withCompletionHandler:^{
                    if (completionBlock) {
                        completionBlock(YES);
                    }
                }];
                return;
            }
                break;
            case BKRVCRStateStopped:
                break;
        }
        if (completionBlock) {
            completionBlock(NO);
        }
    });
}

- (void)pauseWithCompletionBlock:(BKRVCRActionCompletionBlock)completionBlock {
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
                [[BKRRecorder sharedInstance] setEnabled:NO withCompletionHandler:^{
                    if (completionBlock) {
                        completionBlock(YES);
                    }
                }];
                return;
            }
                break;
            case BKRVCRStatePaused:
            case BKRVCRStateStopped:
                break;
        }
        if (completionBlock) {
            completionBlock(NO);
        }
    });
}

- (void)resetWithCompletionBlock:(BKRVCRActionCompletionBlock)completionBlock {
    BKRWeakify(self);
    dispatch_barrier_async(self.accessQueue, ^{
        BKRStrongify(self);
        self->_state = BKRVCRStateStopped;
        [[BKRRecorder sharedInstance] resetWithCompletionBlock:^{
            if (completionBlock) {
                completionBlock(YES);
            }
        }];
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
