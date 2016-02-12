//
//  BKRPlayableVCR.m
//  Pods
//
//  Created by Jordan Zucker on 2/9/16.
//
//

#import "BKRPlayableVCR.h"
#import "BKRPlayer.h"
#import "BKRPlayableCassette.h"
#import "BKRFilePathHelper.h"

@interface BKRPlayableVCR ()
@property (nonatomic, strong) BKRPlayer *player;
@property (nonatomic) dispatch_queue_t accessQueue;

@end

@implementation BKRPlayableVCR

@synthesize beforeAddingStubsBlock = _beforeAddingStubsBlock;
@synthesize afterAddingStubsBlock = _afterAddingStubsBlock;
@synthesize state = _state;
@synthesize cassetteFilePath = _cassetteFilePath;

- (instancetype)initWithMatcherClass:(Class<BKRRequestMatching>)matcherClass {
    self = [super init];
    if (self) {
        _player = [BKRPlayer playerWithMatcherClass:matcherClass];
        _accessQueue = dispatch_queue_create("com.BKR.BKRPlayableVCR", DISPATCH_QUEUE_CONCURRENT);
        _state = BKRVCRStateStopped;
        _cassetteFilePath = nil;
    }
    return self;
}

+ (instancetype)vcrWithMatcherClass:(Class<BKRRequestMatching>)matcherClass {
    return [[self alloc] initWithMatcherClass:matcherClass];
}

#pragma mark - BKRVCRPlaying

- (void)setBeforeAddingStubsBlock:(BKRBeforeAddingStubs)beforeAddingStubsBlock {
    BKRWeakify(self);
    dispatch_barrier_async(self.accessQueue, ^{
        BKRStrongify(self);
        self->_player.beforeAddingStubsBlock = beforeAddingStubsBlock;
    });
}

- (BKRBeforeAddingStubs)beforeAddingStubsBlock {
    __block BKRBeforeAddingStubs stubsBlock = nil;
    BKRWeakify(self);
    dispatch_sync(self.accessQueue, ^{
        BKRStrongify(self);
        stubsBlock = self->_player.beforeAddingStubsBlock;
    });
    return stubsBlock;
}

- (void)setAfterAddingStubsBlock:(BKRAfterAddingStubs)afterAddingStubsBlock {
    BKRWeakify(self);
    dispatch_barrier_async(self.accessQueue, ^{
        BKRStrongify(self);
        self->_player.afterAddingStubsBlock = afterAddingStubsBlock;
    });

}

- (BKRAfterAddingStubs)afterAddingStubsBlock {
    __block BKRAfterAddingStubs stubsBlock = nil;
    BKRWeakify(self);
    dispatch_sync(self.accessQueue, ^{
        BKRStrongify(self);
        stubsBlock = self->_player.afterAddingStubsBlock;
    });
    return stubsBlock;
}

#pragma mark - BKRActions

- (BKRCassette *)currentCassette {
    __block BKRCassette *cassette = nil;
    BKRWeakify(self);
    dispatch_sync(self.accessQueue, ^{
        BKRStrongify(self);
        cassette = (BKRCassette *)self->_player.currentCassette;
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
    BKRWeakify(self);
    dispatch_barrier_async(self.accessQueue, ^{
        BKRStrongify(self);
        switch (self->_state) {
            case BKRVCRStatePaused:
            case BKRVCRStateStopped:
            {
                self->_player.enabled = YES;
                self->_state = BKRVCRStatePlaying;
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

- (void)stop {
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
                self->_player.enabled = NO;
                self->_state = BKRVCRStateStopped;
            }
                break;
            case BKRVCRStatePaused:
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
            case BKRVCRStateUnknown:
            case BKRVCRStateRecording:
            {
                NSLog(@"how did we get here?");
            }
                break;
            case BKRVCRStatePlaying:
            {
                self->_player.enabled = NO;
                self->_state = BKRVCRStatePaused;
            }
                break;
            case BKRVCRStateStopped:
            case BKRVCRStatePaused:
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
    if (![BKRFilePathHelper filePathExists:cassetteFilePath]) {
        NSLog(@"There is no file at this location");
        // should we throw an exception here too??
        return NO;
    }
    __block BOOL finalResult = NO;
    __block NSString *finalPath = nil;
    BKRWeakify(self);
    dispatch_barrier_sync(self.accessQueue, ^{
        BKRStrongify(self);
        NSDictionary *cassetteDictionary = [BKRFilePathHelper dictionaryForPlistFilePath:cassetteFilePath];
        if (cassetteDictionary) {
            // if no cassette dictionary is fetched, then return NO
            self->_cassetteFilePath = cassetteFilePath;
            finalPath = self->_cassetteFilePath;
            BKRPlayableCassette *cassette = [BKRPlayableCassette cassetteFromDictionary:cassetteDictionary];
            self->_player.currentCassette = cassette;
            finalResult = YES;
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

- (BOOL)eject:(BOOL)shouldOverwrite completionHandler:(BKRCassetteHandlingBlock)completionBlock {
    if (!self.cassetteFilePath) {
        NSLog(@"no cassette contained");
        return NO;
    }
    __block BOOL finalResult = NO;
    __block NSString *finalPath = nil;
    [self stop];
    BKRWeakify(self);
    dispatch_barrier_sync(self.accessQueue, ^{
        BKRStrongify(self);
        self->_state = BKRVCRStateStopped;
        finalPath = self->_cassetteFilePath;
        self->_cassetteFilePath = nil;
        [self->_player reset]; // removes cassette
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

- (void)reset {
    BKRWeakify(self);
    dispatch_barrier_async(self.accessQueue, ^{
        BKRStrongify(self);
        [self->_player reset];
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
