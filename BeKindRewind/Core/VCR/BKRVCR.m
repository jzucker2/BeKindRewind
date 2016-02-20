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

- (void)setCurrentVCR:(id<BKRVCRActions>)currentVCR {
    BKRWeakify(self);
    dispatch_barrier_async(self.accessQueue, ^{
        BKRStrongify(self);
        self->_currentVCR = currentVCR;
    });
}

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

- (void)playWithCompletionBlock:(void (^)(void))completionBlock {
    [self executeForVCR:self.playableVCR clearCurrentVCRAtEnd:NO withVCRAction:^(id<BKRVCRActions> vcr) {
        [vcr playWithCompletionBlock:completionBlock];
    }];
}

- (void)pauseWithCompletionBlock:(void (^)(void))completionBlock {
    [self executeForVCR:self.playableVCR clearCurrentVCRAtEnd:NO withVCRAction:^(id<BKRVCRActions> vcr) {
        [vcr pauseWithCompletionBlock:completionBlock];
    }];
}

- (void)stopWithCompletionBlock:(void (^)(void))completionBlock {
    [self executeForVCR:self.playableVCR clearCurrentVCRAtEnd:YES withVCRAction:^(id<BKRVCRActions> vcr) {
        [vcr stopWithCompletionBlock:completionBlock];
    }];
}

- (void)recordWithCompletionBlock:(void (^)(void))completionBlock {
    [self executeForVCR:self.recordableVCR clearCurrentVCRAtEnd:NO withVCRAction:^(id<BKRVCRActions> vcr) {
        [vcr recordWithCompletionBlock:completionBlock];
    }];
}

- (BOOL)insert:(BKRVCRCassetteLoadingBlock)cassetteLoadingBlock completionHandler:(BKRCassetteHandlingBlock)completionBlock {
//    __block BOOL finalResult = NO;
//    BKRWeakify(self);
//    dispatch_barrier_sync(self.accessQueue, ^{
//        __block NSInteger completionBlockCount = 0;
//        BKRStrongify(self);
//        BOOL recordableResult = [self.recordableVCR insert:cassetteFilePath completionHandler:^(BOOL result, NSString *filePath) {
//            completionBlockCount++;
//            if (
//                completionBlock &&
//                (completionBlockCount == 2)
//                ) {
//                completionBlock(result, filePath);
//            }
//        }];
//        
//        BOOL playableResult = YES;
////        BOOL playableResult = [self.playableVCR insert:cassetteFilePath completionHandler:^(BOOL result, NSString *filePath) {
////            completionBlockCount++;
////            if (
////                completionBlock &&
////                (completionBlockCount == 2)
////                ) {
////                completionBlock(result, filePath);
////            }
////        }];
//        
//        finalResult = recordableResult && playableResult;
//    });
//    
//    return finalResult;
    return NO;
}

- (BOOL)eject:(BKRVCRCassetteSavingBlock)cassetteSavingBlock completionHandler:(BKRCassetteHandlingBlock)completionBlock {
//    __block BOOL finalResult = NO;
//    BKRWeakify(self);
//    dispatch_barrier_sync(self.accessQueue, ^{
//        __block NSInteger completionBlockCount = 0;
//        BKRStrongify(self);
//        BOOL recordableResult = [self.recordableVCR eject:shouldOverwrite completionHandler:^(BOOL result, NSString *filePath) {
//            completionBlockCount++;
//            if (
//                completionBlock &&
//                (completionBlockCount == 2)
//                ) {
//                completionBlock(result, filePath);
//            }
//        }];
//        
//        BOOL playableResult = YES;
////        BOOL playableResult = [self.playableVCR eject:shouldOverwrite completionHandler:^(BOOL result, NSString *filePath) {
////            completionBlockCount++;
////            if (
////                completionBlock &&
////                (completionBlockCount == 2)
////                ) {
////                completionBlock(result, filePath);
////            }
////        }];
//        
//        finalResult = recordableResult && playableResult;
//    });
//    
//    return finalResult;
    return NO;
}

- (BKRCassette *)currentCassette {
    __block BKRCassette *cassette = nil;
    BKRWeakify(self);
    dispatch_sync(self.accessQueue, ^{
        BKRStrongify(self);
        // technically this shouldn't matter, both cassettes should be the same
        // but if stop is called, then return the cassette from recorder
//        cassette = [self->_currentVCR currentCassette];
//        if (!cassette) {
//            cassette = [self->_lastVCR currentCassette];
//        }
        cassette = self->_recordableVCR.currentCassette;
    });
    return cassette;
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
