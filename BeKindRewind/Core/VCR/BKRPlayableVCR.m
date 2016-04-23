//
//  BKRPlayableVCR.m
//  Pods
//
//  Created by Jordan Zucker on 2/9/16.
//
//

#import "BKRPlayableVCR.h"
#import "BKRPlayer.h"
#import "BKRConfiguration.h"
#import "BKRCassette+Playable.h"
#import "BKRFilePathHelper.h"
#import "NSObject+BKRVCRAdditions.h"

@interface BKRPlayableVCR ()
@property (nonatomic, strong) BKRPlayer *player;
@property (nonatomic) dispatch_queue_t accessQueue;
@property (nonatomic, copy) BKRConfiguration *configuration;

@end

@implementation BKRPlayableVCR

@synthesize state = _state;

- (instancetype)initWithConfiguration:(BKRConfiguration *)configuration {
    self = [super init];
    if (self) {
        _configuration = configuration.copy;
        _player = [BKRPlayer playerWithConfiguration:_configuration];
        _accessQueue = dispatch_queue_create("com.BKR.BKRPlayableVCR", DISPATCH_QUEUE_CONCURRENT);
        _state = BKRVCRStateStopped;
    }
    return self;
}

+ (instancetype)vcrWithConfiguration:(BKRConfiguration *)configuration {
    return [[self alloc] initWithConfiguration:configuration];
}

+ (instancetype)defaultVCR {
    return [self vcrWithConfiguration:[BKRConfiguration defaultConfiguration]];
}

#pragma mark - Extras

- (id<BKRRequestMatching>)matcher {
    return self.player.matcher;
}

#pragma mark - BKRActions

- (BKRConfiguration *)currentConfiguration {
    return self.configuration.copy;
}

- (BKRCassette *)currentCassette {
    __block BKRCassette *cassette = nil;
    BKRWeakify(self);
    dispatch_sync(self.accessQueue, ^{
        BKRStrongify(self);
        cassette = self->_player.currentCassette;
    });
    return cassette;
}

- (void)playWithCompletionBlock:(BKRVCRActionCompletionBlock)completionBlock {
    BKRWeakify(self);
    dispatch_barrier_async(self.accessQueue, ^{
        BKRStrongify(self);
        switch (self->_state) {
            case BKRVCRStatePaused:
            case BKRVCRStateStopped:
            {
                self->_state = BKRVCRStatePlaying;
                [self->_player setEnabled:YES withCompletionHandler:^{
                    if (completionBlock) {
                        completionBlock(YES);
                    }
                }];
                return;
            }
                break;
            case BKRVCRStateUnknown:
            case BKRVCRStateRecording:
            {
                NSLog(@"how did we get here?");
            }
                break;
            case BKRVCRStatePlaying:
                break;
        }
        if (completionBlock) {
            completionBlock(NO);
        }
    });
}

- (void)recordWithCompletionBlock:(BKRVCRActionCompletionBlock)completionBlock {
    NSLog(@"playing VCR can't record a cassette");
    if (!completionBlock) {
        return;
    }
    dispatch_barrier_async(self.accessQueue, ^{
        completionBlock(NO);
    });
}

- (void)stopWithCompletionBlock:(BKRVCRActionCompletionBlock)completionBlock {
    BKRWeakify(self);
    dispatch_barrier_async(self.accessQueue, ^{
        BKRStrongify(self);
        switch (self->_state) {
            case BKRVCRStateRecording:
            case BKRVCRStateUnknown:
            {
                NSLog(@"how did we get here?");
            }
                break;
            case BKRVCRStatePlaying:
            {
                self->_state = BKRVCRStateStopped;
                [self->_player setEnabled:NO withCompletionHandler:^{
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

- (void)pauseWithCompletionBlock:(BKRVCRActionCompletionBlock)completionBlock {
    BKRWeakify(self);
    dispatch_barrier_async(self.accessQueue, ^{
        BKRStrongify(self);
        switch (self->_state) {
            case BKRVCRStateUnknown:
            case BKRVCRStateRecording:
            {
                NSLog(@"how did we get here?");
            }
                break;
            case BKRVCRStatePlaying:
            {
                self->_state = BKRVCRStatePaused;
                [self->_player setEnabled:NO withCompletionHandler:^{
                    if (completionBlock) {
                        completionBlock(YES);
                    }
                }];
                return;
            }
                break;
            case BKRVCRStateStopped:
            case BKRVCRStatePaused:
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
    BKRWeakify(self);
    dispatch_barrier_sync(self.accessQueue, ^{
        BKRStrongify(self);
        if (!cassetteLoadingBlock) {
            finalResult = NO;
            return;
        }
        
        BKRCassette *loadingCassette = cassetteLoadingBlock();
        // if no cassette dictionary is fetched, then return NO
        finalResult = (loadingCassette ? YES : NO);
        self->_player.currentCassette = loadingCassette;
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
    [self stopWithCompletionBlock:nil]; // no completion block to call
    BKRWeakify(self);
    dispatch_barrier_sync(self.accessQueue, ^{
        BKRStrongify(self);
        if (self->_state == BKRVCRStateUnknown) {
            NSLog(@"what happened, how did we get in this state? Please open a GitHub issue");
            return;
        }
        self->_state = BKRVCRStateStopped; // this is redundant from the `stopWithCompletionBlock:` call up above
        [self->_player resetWithCompletionBlock:nil]; // removes cassette
        finalResult = YES;
    });
    [self BKR_executeCassetteHandlingBlockWithFinalResult:finalResult onMainQueue:completionBlock];
    return finalResult;
}

- (void)resetWithCompletionBlock:(BKRVCRActionCompletionBlock)completionBlock {
    BKRWeakify(self);
    dispatch_barrier_async(self.accessQueue, ^{
        BKRStrongify(self);
        self->_state = BKRVCRStateStopped;
        [self->_player resetWithCompletionBlock:^{
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
