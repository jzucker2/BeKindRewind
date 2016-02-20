//
//  BKRPlayableVCR.m
//  Pods
//
//  Created by Jordan Zucker on 2/9/16.
//
//

#import "BKRPlayableVCR.h"
#import "BKRPlayer.h"
#import "BKRCassette+Playable.h"
#import "BKRFilePathHelper.h"
#import "NSObject+BKRVCRAdditions.h"

@interface BKRPlayableVCR ()
@property (nonatomic, strong) BKRPlayer *player;
@property (nonatomic) dispatch_queue_t accessQueue;

@end

@implementation BKRPlayableVCR

@synthesize state = _state;
//@synthesize cassetteFilePath = _cassetteFilePath;

- (instancetype)initWithMatcherClass:(Class<BKRRequestMatching>)matcherClass {
    self = [super init];
    if (self) {
        _player = [BKRPlayer playerWithMatcherClass:matcherClass];
        _accessQueue = dispatch_queue_create("com.BKR.BKRPlayableVCR", DISPATCH_QUEUE_CONCURRENT);
        _state = BKRVCRStateStopped;
//        _cassetteFilePath = nil;
    }
    return self;
}

+ (instancetype)vcrWithMatcherClass:(Class<BKRRequestMatching>)matcherClass {
    return [[self alloc] initWithMatcherClass:matcherClass];
}

#pragma mark - BKRActions

- (BKRCassette *)currentCassette {
    __block BKRCassette *cassette = nil;
    BKRWeakify(self);
    dispatch_sync(self.accessQueue, ^{
        BKRStrongify(self);
        cassette = self->_player.currentCassette;
    });
    return cassette;
}

//- (NSString *)cassetteFilePath {
//    __block NSString *currentCassetteFilePath = nil;
//    BKRWeakify(self);
//    dispatch_sync(self.accessQueue, ^{
//        BKRStrongify(self);
//        currentCassetteFilePath = self->_cassetteFilePath;
//    });
//    return currentCassetteFilePath;
//}

- (void)playWithCompletionBlock:(void (^)(void))completionBlock {
    BKRWeakify(self);
    dispatch_barrier_async(self.accessQueue, ^{
        BKRStrongify(self);
        switch (self->_state) {
            case BKRVCRStatePaused:
            case BKRVCRStateStopped:
            {
                self->_state = BKRVCRStatePlaying;
                [self->_player setEnabled:YES withCompletionHandler:completionBlock];
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
    });
}

- (void)recordWithCompletionBlock:(void (^)(void))completionBlock {
    // no-op
    NSLog(@"playing VCR can't record a cassette");
}

- (void)stopWithCompletionBlock:(void (^)(void))completionBlock {
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
                [self->_player setEnabled:NO withCompletionHandler:completionBlock];
            }
                break;
            case BKRVCRStatePaused:
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
            case BKRVCRStateUnknown:
            case BKRVCRStateRecording:
            {
                NSLog(@"how did we get here?");
            }
                break;
            case BKRVCRStatePlaying:
            {
                self->_state = BKRVCRStatePaused;
                [self->_player setEnabled:NO withCompletionHandler:completionBlock];
            }
                break;
            case BKRVCRStateStopped:
            case BKRVCRStatePaused:
                break;
        }
    });
}

- (BOOL)insert:(BKRVCRCassetteLoadingBlock)cassetteLoadingBlock completionHandler:(BKRCassetteHandlingBlock)completionBlock {
    // can't insert a cassette if you already have one
    if (self.currentCassette) {
        NSLog(@"Already contains a cassette");
        [self BKR_executeCassetteHandlingBlockWithFinalResult:NO andCassetteFilePath:nil onMainQueue:completionBlock];
        return NO;
    }
//    NSParameterAssert(cassetteFilePath);
//    NSParameterAssert([cassetteFilePath.pathExtension isEqualToString:@"plist"]);
//    if (![BKRFilePathHelper filePathExists:cassetteFilePath]) {
//        NSLog(@"There is no file at this location");
//        // should we throw an exception here too??
//        [self BKR_executeCassetteHandlingBlockWithFinalResult:NO andCassetteFilePath:cassetteFilePath onMainQueue:completionBlock];
//        return NO;
//    }
    __block BOOL finalResult = NO;
    BKRWeakify(self);
    dispatch_barrier_sync(self.accessQueue, ^{
        BKRStrongify(self);
        if (!cassetteLoadingBlock) {
            finalResult = NO;
            return;
        }
//         if no cassette dictionary is fetched, then return NO
//        self->_player.currentCassette = cassetteLoadingBlock();
//        finalResult = YES;
        
        BKRCassette *loadingCassette = cassetteLoadingBlock();
        NSLog(@"loading cassette: %@", loadingCassette);
        // if no cassette dictionary is fetched, then return NO
        finalResult = (loadingCassette ? YES : NO);
        self->_player.currentCassette = loadingCassette;
    });
    [self BKR_executeCassetteHandlingBlockWithFinalResult:finalResult andCassetteFilePath:nil onMainQueue:completionBlock];
    return finalResult;
}

//- (BOOL)insert:(NSString *)cassetteFilePath completionHandler:(BKRCassetteHandlingBlock)completionBlock {
//    NSDictionary *cassetteDictionary = [BKRFilePathHelper dictionaryForPlistFilePath:cassetteFilePath];
//    BKRCassette *cassette = nil;
//    if (cassetteDictionary) {
//        cassette = [BKRCassette cassetteFromDictionary:cassetteDictionary];
//    } else {
//        cassette = [BKRCassette cassette];
//    }
//    [self insert:cassette withFilePath:cassetteFilePath completionHandler:completionBlock];
//    // can't insert a cassette if you already have one
//    if (self.cassetteFilePath) {
//        NSLog(@"Already contains a cassette");
//        [self BKR_executeCassetteHandlingBlockWithFinalResult:NO andCassetteFilePath:cassetteFilePath onMainQueue:completionBlock];
//        return NO;
//    }
//    NSParameterAssert(cassetteFilePath);
//    NSParameterAssert([cassetteFilePath.pathExtension isEqualToString:@"plist"]);
//    if (![BKRFilePathHelper filePathExists:cassetteFilePath]) {
//        NSLog(@"There is no file at this location");
//        // should we throw an exception here too??
//        [self BKR_executeCassetteHandlingBlockWithFinalResult:NO andCassetteFilePath:cassetteFilePath onMainQueue:completionBlock];
//        return NO;
//    }
//    __block BOOL finalResult = NO;
//    __block NSString *finalPath = nil;
//    BKRWeakify(self);
//    dispatch_barrier_sync(self.accessQueue, ^{
//        BKRStrongify(self);
//        NSDictionary *cassetteDictionary = [BKRFilePathHelper dictionaryForPlistFilePath:cassetteFilePath];
//        if (cassetteDictionary) {
//            // if no cassette dictionary is fetched, then return NO
//            self->_cassetteFilePath = cassetteFilePath;
//            finalPath = self->_cassetteFilePath;
//            BKRCassette *cassette = [BKRCassette cassetteFromDictionary:cassetteDictionary];
//            self->_player.currentCassette = cassette;
//            finalResult = YES;
//        }
//    });
//    [self BKR_executeCassetteHandlingBlockWithFinalResult:finalResult andCassetteFilePath:finalPath onMainQueue:completionBlock];
//    return finalResult;
//}

- (BOOL)eject:(BKRVCRCassetteSavingBlock)cassetteSavingBlock completionHandler:(BKRCassetteHandlingBlock)completionBlock {
    if (!self.currentCassette) {
        NSLog(@"no cassette contained");
        [self BKR_executeCassetteHandlingBlockWithFinalResult:NO andCassetteFilePath:nil onMainQueue:completionBlock];
        return NO;
    }
    __block BOOL finalResult = NO;
//    __block NSString *finalPath = nil;
    [self stopWithCompletionBlock:nil]; // no completion block to call
    BKRWeakify(self);
    dispatch_barrier_sync(self.accessQueue, ^{
        BKRStrongify(self);
        if (self->_state == BKRVCRStateUnknown) {
            NSLog(@"what happened, how did we get in this state? Please open a GitHub issue");
            return;
        }
        self->_state = BKRVCRStateStopped; // this is redundant from the `stopWithCompletionBlock:` call up above
//        finalPath = self->_cassetteFilePath;
//        self->_cassetteFilePath = nil;
        [self->_player resetWithCompletionBlock:nil]; // removes cassette
        finalResult = YES;
    });
    [self BKR_executeCassetteHandlingBlockWithFinalResult:finalResult andCassetteFilePath:nil onMainQueue:completionBlock];
    return finalResult;
//    return NO;
}

- (void)resetWithCompletionBlock:(void (^)(void))completionBlock {
    BKRWeakify(self);
    dispatch_barrier_async(self.accessQueue, ^{
        BKRStrongify(self);
//        self->_cassetteFilePath = nil;
        self->_state = BKRVCRStateStopped;
        [self->_player resetWithCompletionBlock:completionBlock];
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
