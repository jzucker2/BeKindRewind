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

@interface BKRVCR ()
//@property (nonatomic, strong) BKRPlayer *player;
@property (nonatomic) dispatch_queue_t accessQueue;
@property (nonatomic) Class<BKRRequestMatching> matcherClass;
@property (nonatomic, strong) id<BKRVCRActions> internalVCR;
//@property (nonatomic, strong, readwrite) BKRCassette *currentCassette;
//@property (nonatomic, assign, readwrite) BKRVCRState state;
//@property (nonatomic, copy, readwrite) NSString *cassetteFilePath;
@end

@implementation BKRVCR
//@synthesize currentCassette = _currentCassette;
@synthesize cassetteFilePath = _cassetteFilePath;
@synthesize state = _state;
@synthesize matcherClass = _matcherClass;
@synthesize internalVCR = _internalVCR;
//@synthesize afterAddingStubsBlock = _afterAddingStubsBlock;
//@synthesize beforeAddingStubsBlock = _beforeAddingStubsBlock;
//@synthesize beginRecordingBlock = _beginRecordingBlock;
//@synthesize endRecordingBlock = _endRecordingBlock;

- (instancetype)initWithMatcherClass:(Class<BKRRequestMatching>)matcherClass {
    self = [super init];
    if (self) {
//        _player = [BKRPlayer playerWithMatcherClass:matcherClass];
//        _player.enabled = NO;
//        [BKRRecorder sharedInstance].enabled = NO;
        _matcherClass = matcherClass;
        _accessQueue = dispatch_queue_create("com.BKR.VCR.processingQueue", DISPATCH_QUEUE_CONCURRENT);
        _state = BKRVCRStateStopped;
        _cassetteFilePath = nil;
        _internalVCR = nil;
//        _currentCassette = nil;
//        _cassetteFilePath = nil;
//        _disabled = NO;
//        _recording = NO;
    }
    return self;
}

+ (instancetype)vcrWithMatcherClass:(Class<BKRRequestMatching>)matcherClass {
    return [[self alloc] initWithMatcherClass:matcherClass];
}

- (id<BKRRequestMatching>)matcher {
//    return self.player.matcher;
    return nil;
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
//    BKRWeakify(self);
    
}

- (void)pause {
    
}

- (void)stop {
    
}

- (void)recordWithCompletionBlock:(void (^)(void))completionBlock {
    
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

- (void)reset {
    BKRWeakify(self);
    dispatch_barrier_async(self.accessQueue, ^{
        BKRStrongify(self);
        [self->_internalVCR reset];
        self->_cassetteFilePath = nil;
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
