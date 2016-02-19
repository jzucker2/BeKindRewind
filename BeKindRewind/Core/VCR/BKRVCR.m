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
@property (nonatomic, strong) id<BKRVCRActions> internalVCR;
@property (nonatomic, strong) BKRRecordableVCR *recordableVCR;
@property (nonatomic, strong) BKRPlayableVCR *playableVCR;
@end

@implementation BKRVCR
@synthesize cassetteFilePath = _cassetteFilePath;
@synthesize state = _state;
@synthesize internalVCR = _internalVCR;
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
        _internalVCR = nil;
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

- (void)setInternalVCR:(id<BKRVCRActions>)internalVCR {
    BKRWeakify(self);
    dispatch_barrier_async(self.accessQueue, ^{
        BKRStrongify(self);
        self->_internalVCR = internalVCR;
    });
}

- (id<BKRVCRActions>)internalVCR {
    __block id<BKRVCRActions> currentInternalVCR = nil;
    dispatch_sync(self.accessQueue, ^{
        currentInternalVCR = self->_internalVCR;
    });
    return currentInternalVCR;
}

#pragma mark - BKRVCRActions

- (void)playWithCompletionBlock:(void (^)(void))completionBlock {
    [self.internalVCR playWithCompletionBlock:completionBlock];
}

- (void)pauseWithCompletionBlock:(void (^)(void))completionBlock {
    [self.internalVCR pauseWithCompletionBlock:completionBlock];
}

- (void)stopWithCompletionBlock:(void (^)(void))completionBlock {
    
}

- (void)recordWithCompletionBlock:(void (^)(void))completionBlock {
    [self.internalVCR recordWithCompletionBlock:completionBlock];
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
        cassette = [self->_internalVCR currentCassette];
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
        [self->_internalVCR resetWithCompletionBlock:nil];
        self->_cassetteFilePath = nil;
        self->_state = BKRVCRStateStopped;
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }
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
