//
//  BKRRecordableVCR.m
//  Pods
//
//  Created by Jordan Zucker on 2/9/16.
//
//

#import "BKRRecordableVCR.h"
#import "BKRConstants.h"
#import "BKRRecordableCassette.h"
#import "BKRFilePathHelper.h"
#import "BKRRecorder.h"

@interface BKRRecordableVCR ()
@property (nonatomic) dispatch_queue_t accessQueue;
//@property (nonatomic, copy, readwrite) NSString *cassetteFilePath;
@property (nonatomic, assign, readwrite) BOOL shouldSaveEmptyCassette; // no by default
@end

@implementation BKRRecordableVCR

@synthesize state = _state;
@synthesize cassetteFilePath = _cassetteFilePath;
@synthesize beginRecordingBlock = _beginRecordingBlock;
@synthesize endRecordingBlock = _endRecordingBlock;

- (instancetype)initWithEmptyCassetteOption:(BOOL)shouldSaveEmptyCassette {
    self = [super init];
    if (self) {
        [[BKRRecorder sharedInstance] reset];
        _accessQueue = dispatch_queue_create("com.BKR.RecordableVCR", DISPATCH_QUEUE_CONCURRENT);
        _state = BKRVCRStateStopped;
        _cassetteFilePath = nil;
        _shouldSaveEmptyCassette = shouldSaveEmptyCassette;
    }
    return self;
}

+ (instancetype)vcrWithCassetteSavingOption:(BOOL)shouldSaveEmptyCassette {
    return [[self alloc] initWithEmptyCassetteOption:shouldSaveEmptyCassette];
}

+ (instancetype)vcr {
    return [self vcrWithCassetteSavingOption:NO];
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
        cassette = (BKRCassette *)[BKRRecorder sharedInstance].currentCassette;
    });
    return cassette;
}

- (NSString *)cassetteFilePath {
    __block NSString *currentCassetteFilePath = nil;
    BKRWeakify(self);
    dispatch_sync(self.accessQueue, ^{
        BKRStrongify(self);
        currentCassetteFilePath = self->_cassetteFilePath;
    });
    return currentCassetteFilePath;
}

- (void)playWithCompletionBlock:(void (^)(void))completionBlock {
    // no-op
    NSLog(@"recording VCR can't play a cassette");
}

- (void)recordWithCompletionBlock:(void (^)(void))completionBlock {
    BKRWeakify(self);
    NSLog(@"before queueing record");
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
                NSLog(@"about to enable recorder");
                [BKRRecorder sharedInstance].enabled = YES;
                NSLog(@"enabled recorder");
                self->_state = BKRVCRStateRecording;
                if (completionBlock) {
                    if ([NSThread isMainThread]) {
                        completionBlock();
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionBlock();
                        });
                    }
                }
            }
                break;
        }
    });
}

- (BOOL)insert:(NSString *)cassetteFilePath completionHandler:(BKRCassetteHandlingBlock)completionBlock {
    // can't insert a cassette if you already have one
    if (self.cassetteFilePath) {
        NSLog(@"Already contains a cassette");
        return NO;
    }
    NSParameterAssert(cassetteFilePath);
    NSParameterAssert([cassetteFilePath.pathExtension isEqualToString:@"plist"]);
    __block BOOL finalResult = NO;
    __block NSString *finalPath = nil;
    BKRWeakify(self);
    dispatch_barrier_sync(self.accessQueue, ^{
        BKRStrongify(self);
        NSLog(@"loading cassette at: %@", cassetteFilePath);
        self->_cassetteFilePath = cassetteFilePath;
        finalPath = self->_cassetteFilePath;
        [BKRRecorder sharedInstance].currentCassette = [BKRRecordableCassette cassette];
        finalResult = YES;
    });
    if (completionBlock) {
        if ([NSThread isMainThread]) {
            completionBlock(finalResult, finalPath);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(finalResult, finalPath);
            });
        }
    }
    return finalResult;
}

- (BOOL)eject:(BOOL)shouldOverwrite completionHandler:(BKRCassetteHandlingBlock)completionBlock {
    if (!self.cassetteFilePath) {
        NSLog(@"no cassette contained");
        return NO;
    }
    __block BOOL finalResult = NO;
    __block NSString *finalPath = nil;
    [self stop]; // call a stop
    BKRWeakify(self);
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
            return;
        }
        NSString *currentFilePath = self->_cassetteFilePath;
        if (!currentFilePath) {
            NSLog(@"there is not path to save a file to! How did we get here? Open a GitHub issue with repro steps");
            return;
        }
        BOOL fileExists = [BKRFilePathHelper filePathExists:currentFilePath];
        if (
            !fileExists || // if the file path does not exist, then just save it!
            (fileExists && shouldOverwrite) // if there's a place to save and it already exists, then only save if overwriting
            ) {
            NSDictionary *cassetteDictionary = [BKRRecorder sharedInstance].plistDictionary;
            finalPath = currentFilePath;
            finalResult = [BKRFilePathHelper writeDictionary:cassetteDictionary toFile:currentFilePath];
            NSLog(@"writing result to: %@", finalPath);
            self->_state = BKRVCRStateStopped; // somewhat unnecessary
            self->_cassetteFilePath = nil; // remove the cassette file path
            [[BKRRecorder sharedInstance] reset]; // reset the recorder (removes cassette)
        }
    });
    if (completionBlock) {
        if ([NSThread isMainThread]) {
            completionBlock(finalResult, finalPath);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(finalResult, finalPath);
            });
        }
    }
    return finalResult;
}

- (void)stop {
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
                [BKRRecorder sharedInstance].enabled = NO;
                self->_state = BKRVCRStateStopped;
            }
                break;
            case BKRVCRStateStopped:
                break;
        }
    });
}

- (void)pause {
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
                [BKRRecorder sharedInstance].enabled = NO;
                self->_state = BKRVCRStatePaused;
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
    dispatch_barrier_sync(self.accessQueue, ^{
        BKRStrongify(self);
        [[BKRRecorder sharedInstance] reset];
        self->_cassetteFilePath = nil;
        self->_state = BKRVCRStateStopped;
    });
    if (completionBlock) {
        if ([NSThread isMainThread]) {
            completionBlock();
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }
    }
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
