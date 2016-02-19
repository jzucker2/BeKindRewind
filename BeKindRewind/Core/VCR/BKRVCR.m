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

@interface BKRVCR ()
@property (nonatomic) dispatch_queue_t accessQueue;
@property (nonatomic, strong) id<BKRVCRActions> currentVCR;
@property (nonatomic, strong) BKRRecordableVCR *recordableVCR;
@property (nonatomic, strong) BKRPlayableVCR *playableVCR;
@end

@implementation BKRVCR
@synthesize cassetteFilePath = _cassetteFilePath;
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
        _cassetteFilePath = nil;
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

- (void)setCurrentVCR:(id<BKRVCRActions>)currentVCR {
    BKRWeakify(self);
    dispatch_barrier_async(self.accessQueue, ^{
        BKRStrongify(self);
        self->_currentVCR = internalVCR;
    });
}

- (id<BKRVCRActions>)internalVCR {
    __block id<BKRVCRActions> currentInternalVCR = nil;
    dispatch_sync(self.accessQueue, ^{
        currentInternalVCR = self->_currentVCR;
    });
    return currentInternalVCR;
}

#pragma mark - BKRVCRActions

- (void)playWithCompletionBlock:(void (^)(void))completionBlock {
    [self.currentVCR playWithCompletionBlock:completionBlock];
}

- (void)pauseWithCompletionBlock:(void (^)(void))completionBlock {
    [self.currentVCR pauseWithCompletionBlock:completionBlock];
}

- (void)stopWithCompletionBlock:(void (^)(void))completionBlock {
    
}

- (void)recordWithCompletionBlock:(void (^)(void))completionBlock {
    [self.currentVCR recordWithCompletionBlock:completionBlock];
}

- (BOOL)insert:(NSString *)cassetteFilePath completionHandler:(BKRCassetteHandlingBlock)completionBlock {
    return NO;
}

- (BOOL)eject:(BOOL)shouldOverwrite completionHandler:(BKRCassetteHandlingBlock)completionBlock {
    return NO;
}

- (BKRCassette *)currentCassette {
    __block BKRCassette *cassette = nil;
    BKRWeakify(self);
    dispatch_sync(self.accessQueue, ^{
        BKRStrongify(self);
        // technically this shouldn't matter, both cassettes should be the same
        cassette = [self->_currentVCR currentCassette];
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

- (void)resetWithCompletionBlock:(void (^)(void))completionBlock {
    // this is weird, double completion blocks?
    // set a block variable for 0, count up for each completion shop,
    // run the block on main queue when you hit 2
    BKRWeakify(self);
    dispatch_barrier_async(self.accessQueue, ^{
        BKRStrongify(self);
        __block NSInteger completionBlockCount = 0;
        [self->_recordableVCR resetWithCompletionBlock:^{
            completionBlockCount++;
            if (
                completionBlock &&
                (completionBlockCount == 2)
                ) {
                completionBlock();
            }
        }];
        [self->_playableVCR resetWithCompletionBlock:^{
            completionBlockCount++;
            if (
                completionBlock &&
                (completionBlockCount == 2)
                ) {
                completionBlock();
            }
        }];
        self->_currentVCR = nil;
        self->_cassetteFilePath = nil;
        self->_state = BKRVCRStateStopped;
//        if (completionBlock) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                completionBlock();
//            });
//        }
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
