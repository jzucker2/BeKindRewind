//
//  BKRVCR.m
//  Pods
//
//  Created by Jordan Zucker on 1/19/16.
//
//

#import "BKRVCR.h"
#import "BKRCassette.h"
#import "BKRRecorder.h"
#import "BKRPlayer.h"
#import "BKRFilePathHelper.h"
#import "BKRRecordableCassette.h"
#import "BKRPlayableCassette.h"

@interface BKRVCR ()
@property (nonatomic, strong) BKRPlayer *player;
@property (nonatomic) dispatch_queue_t processingQueue;
@property (nonatomic, strong, readwrite) BKRCassette *currentCassette;
@property (nonatomic, assign, readwrite) BKRVCRState state;
@property (nonatomic, copy, readwrite) NSString *cassetteFilePath;
@end

@implementation BKRVCR
@synthesize currentCassette = _currentCassette;
@synthesize state = _state;
//@synthesize afterAddingStubsBlock = _afterAddingStubsBlock;
//@synthesize beforeAddingStubsBlock = _beforeAddingStubsBlock;
//@synthesize beginRecordingBlock = _beginRecordingBlock;
//@synthesize endRecordingBlock = _endRecordingBlock;

- (instancetype)initWithMatcherClass:(Class<BKRRequestMatching>)matcherClass {
    self = [super init];
    if (self) {
        _player = [BKRPlayer playerWithMatcherClass:matcherClass];
        [BKRRecorder sharedInstance].enabled = NO;
        _processingQueue = dispatch_queue_create("com.BKR.VCR.processingQueue", DISPATCH_QUEUE_CONCURRENT);
        _state = BKRVCRStateStopped;
        _currentCassette = nil;
        _cassetteFilePath = nil;
//        _disabled = NO;
//        _recording = NO;
    }
    return self;
}

+ (instancetype)vcrWithMatcherClass:(Class<BKRRequestMatching>)matcherClass {
    return [[self alloc] initWithMatcherClass:matcherClass];
}

- (id<BKRRequestMatching>)matcher {
    return self.player.matcher;
}

#pragma mark - BKRVCRActions


@end
