//
//  BKRVCR.m
//  Pods
//
//  Created by Jordan Zucker on 1/19/16.
//
//

#import "BKRVCR.h"
#import "BKRCassette.h"
#import "BKRFilePathHelper.h"
#import "BKRRecordableVCR.h"
#import "BKRPlayableVCR.h"

typedef void (^BKRVCRActionProcessingBlock)(id<BKRVCRActions> vcr);
typedef void (^BKRVCRCassetteProcessingBlock)(BKRCassette *cassette);

@interface BKRVCR ()
@property (nonatomic) dispatch_queue_t accessQueue;
@property (nonatomic, strong) id<BKRVCRActions> currentVCR;
@property (nonatomic, strong) BKRRecordableVCR *recordableVCR;
@property (nonatomic, strong) BKRPlayableVCR *playableVCR;
@end

@implementation BKRVCR
@synthesize state = _state;
@synthesize currentVCR = _currentVCR;
@synthesize beginRecordingBlock = _beginRecordingBlock;
@synthesize endRecordingBlock = _endRecordingBlock;
@synthesize recordableVCR = _recordableVCR;
@synthesize playableVCR = _playableVCR;

- (instancetype)initWithMatcherClass:(Class<BKRRequestMatching>)matcherClass andEmptyCassetteSavingOption:(BOOL)shouldSaveEmptyCassette {
    self = [super init];
    if (self) {
        _accessQueue = dispatch_queue_create("com.BKR.VCR.accessQueue", DISPATCH_QUEUE_CONCURRENT);
        _state = BKRVCRStateStopped;
        _currentVCR = nil;
        _playableVCR = [BKRPlayableVCR vcrWithMatcherClass:matcherClass];
        _recordableVCR = [BKRRecordableVCR vcrWithEmptyCassetteSavingOption:shouldSaveEmptyCassette];
    }
    return self;
}

+ (instancetype)vcrWithMatcherClass:(Class<BKRRequestMatching>)matcherClass andEmptyCassetteSavingOption:(BOOL)shouldSaveEmptyCassette {
    return [[self alloc] initWithMatcherClass:matcherClass andEmptyCassetteSavingOption:shouldSaveEmptyCassette];
}

- (id<BKRRequestMatching>)matcher {
    return self.playableVCR.matcher;
}

- (BOOL)shouldSaveEmptyCassette {
    return self.recordableVCR.shouldSaveEmptyCassette;
}

#pragma mark - helpers

- (id<BKRVCRActions>)currentVCR {
    __block id<BKRVCRActions> currentInternalVCR = nil;
    BKRWeakify(self);
    dispatch_sync(self.accessQueue, ^{
        BKRStrongify(self);
        currentInternalVCR = self->_currentVCR;
    });
    return currentInternalVCR;
}

- (void)executeForVCR:(id<BKRVCRActions>)desiredVCR clearCurrentVCRAtEnd:(BOOL)clearAfter withVCRAction:(BKRVCRActionProcessingBlock)vcrActionBlock {
    BKRWeakify(self);
    dispatch_barrier_async(self.accessQueue, ^{
        BKRStrongify(self);
        // if the currentVCR is nil, then set it with the desiredVCR value
        if (!self->_currentVCR) {
            self->_currentVCR = desiredVCR; // set the new current VCR
        }
        if (vcrActionBlock) {
            vcrActionBlock(self->_currentVCR);
        }
        if (clearAfter) {
            self->_currentVCR = nil;
        }
    });
}

#pragma mark - BKRVCRActions

- (void)playWithCompletionBlock:(BKRVCRActionCompletionBlock)completionBlock {
    BKRWeakify(self);
    [self executeForVCR:self.playableVCR clearCurrentVCRAtEnd:NO withVCRAction:^(id<BKRVCRActions> vcr) {
        [vcr playWithCompletionBlock:^(BOOL result) {
            BKRStrongify(self);
            if (result) {
                self->_state = BKRVCRStatePlaying;
            }
            if (completionBlock) {
                completionBlock(result);
            }
        }];
        
    }];
}

- (void)pauseWithCompletionBlock:(BKRVCRActionCompletionBlock)completionBlock {
    BKRWeakify(self);
    [self executeForVCR:self.playableVCR clearCurrentVCRAtEnd:NO withVCRAction:^(id<BKRVCRActions> vcr) {
        [vcr pauseWithCompletionBlock:^(BOOL result) {
            BKRStrongify(self);
            if (result) {
                self->_state = BKRVCRStatePaused;
            }
            if (completionBlock) {
                completionBlock(result);
            }
        }];
    }];
}

- (void)stopWithCompletionBlock:(BKRVCRActionCompletionBlock)completionBlock {
    BKRWeakify(self);
    [self executeForVCR:self.playableVCR clearCurrentVCRAtEnd:YES withVCRAction:^(id<BKRVCRActions> vcr) {
        [vcr stopWithCompletionBlock:^(BOOL result) {
            BKRStrongify(self);
            if (result) {
                self->_state = BKRVCRStateStopped;
            }
            if (completionBlock) {
                completionBlock(result);
            }
        }];
    }];
}

- (void)recordWithCompletionBlock:(BKRVCRActionCompletionBlock)completionBlock {
    BKRWeakify(self);
    NSLog(@"%@: start recording", self);
    [self executeForVCR:self.recordableVCR clearCurrentVCRAtEnd:NO withVCRAction:^(id<BKRVCRActions> vcr) {
        NSLog(@"%@ record", self);
        [vcr recordWithCompletionBlock:^(BOOL result) {
            BKRStrongify(self);
            if (result) {
                self->_state = BKRVCRStateRecording;
            }
            NSLog(@"%@ run recording completionblock", self);
            if (completionBlock) {
                completionBlock(result);
            }
        }];
    }];
}

- (BOOL)insert:(BKRVCRCassetteLoadingBlock)cassetteLoadingBlock completionHandler:(BKRCassetteHandlingBlock)completionBlock {
    __block BOOL finalResult = NO;
    BKRWeakify(self);
    dispatch_barrier_sync(self.accessQueue, ^{
        __block NSInteger completionBlockCount = 0;
        BKRStrongify(self);
        if (!cassetteLoadingBlock) {
            finalResult = NO;
            return;
        }
        __block BKRCassette *cassette = cassetteLoadingBlock();
        BKRVCRCassetteLoadingBlock loadingBlock = ^BKRCassette *(void) {
            return cassette;
        };
        BOOL recordableResult = [self->_recordableVCR insert:loadingBlock completionHandler:^(BOOL result) {
            completionBlockCount++;
            if (
                completionBlock &&
                (completionBlockCount == 2)
                ) {
                completionBlock(result);
            }
        }];
        
        BOOL playableResult = [self->_playableVCR insert:loadingBlock completionHandler:^(BOOL result) {
            completionBlockCount++;
            if (
                completionBlock &&
                (completionBlockCount == 2)
                ) {
                completionBlock(result);
            }
        }];
        finalResult = recordableResult && playableResult;
    });
    
    return finalResult;
}

- (BOOL)eject:(BKRVCRCassetteSavingBlock)cassetteSavingBlock completionHandler:(BKRCassetteHandlingBlock)completionBlock {
    NSLog(@"%@ eject", self);
    __block BOOL finalResult = NO;
    NSLog(@"%@ call stop", self);
    [self stopWithCompletionBlock:nil]; // call a stop, no completion necessary, not done yet
    BKRWeakify(self);
    dispatch_barrier_sync(self.accessQueue, ^{
        NSLog(@"%@: enter barrier", self);
        __block NSInteger completionBlockCount = 0;
        BKRStrongify(self);
        if (!cassetteSavingBlock) {
            finalResult = NO;
            return;
        }
        // take from the recordableVCR because that's being added to
        BKRCassette *lastCassette = self->_recordableVCR.currentCassette;
        if (!lastCassette) {
            finalResult = NO;
            return;
        }
        NSString *cassetteFilePath = cassetteSavingBlock(lastCassette);
        BKRVCRCassetteSavingBlock savingBlock = ^NSString *(BKRCassette *cassette) {
            return cassetteFilePath;
        };
        BOOL recordableResult = [self->_recordableVCR eject:savingBlock completionHandler:^(BOOL result) {
            NSLog(@"%@ eject recordable completion block", self);
            completionBlockCount++;
            if (
                completionBlock &&
                (completionBlockCount == 2)
                ) {
                completionBlock(result);
            }
        }];
        
        BOOL playableResult = [self->_playableVCR eject:savingBlock completionHandler:^(BOOL result) {
            NSLog(@"%@ eject playable completion block", self);
            completionBlockCount++;
            if (
                completionBlock &&
                (completionBlockCount == 2)
                ) {
                completionBlock(result);
            }
        }];
        self->_state = BKRVCRStateStopped; // redundant because of stop call above
        finalResult = recordableResult && playableResult;
    });
    NSLog(@"%@ end of eject", self);
    return finalResult;
}

- (BKRCassette *)currentCassette {
    __block BKRCassette *cassette = nil;
    BKRWeakify(self);
    dispatch_sync(self.accessQueue, ^{
        BKRStrongify(self);
        // technically this shouldn't matter, both cassettes should be the same
        // but if stop is called, then return the cassette from recorder
        cassette = self->_recordableVCR.currentCassette;
    });
    return cassette;
}

- (void)resetWithCompletionBlock:(BKRVCRActionCompletionBlock)completionBlock {
    // this is weird, double completion blocks?
    // set a block variable for 0, count up for each completion shop,
    // run the block on main queue when you hit 2
    BKRWeakify(self);
    NSLog(@"%@: begin resetting", self);
    dispatch_barrier_async(self.accessQueue, ^{
        BKRStrongify(self);
        __block NSInteger completionBlockCount = 0;
        [self->_recordableVCR resetWithCompletionBlock:^(BOOL result) {
            NSLog(@"%@: recordable resetCompletionBlock: %ld", self, (long)completionBlockCount);
            completionBlockCount++;
            NSLog(@"%@: recordable resetCompletionBlock: %ld", self, (long)completionBlockCount);
            if (
                completionBlock &&
                (completionBlockCount == 2)
                ) {
                NSLog(@"%@: recordable run completion block", self);
                completionBlock(YES);
            }
        }];
        [self->_playableVCR resetWithCompletionBlock:^(BOOL result) {
            NSLog(@"%@: playable resetCompletionBlock: %ld", self, (long)completionBlockCount);
            completionBlockCount++;
            NSLog(@"%@: playable resetCompletionBlock: %ld", self, (long)completionBlockCount);
            if (
                completionBlock &&
                (completionBlockCount == 2)
                ) {
                NSLog(@"%@: playable run completion block", self);
                completionBlock(YES);
            }
        }];
        self->_currentVCR = nil;
        self->_state = BKRVCRStateStopped;
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
