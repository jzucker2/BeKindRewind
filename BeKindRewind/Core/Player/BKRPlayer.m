//
//  BKRPlayer.m
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import <OHHTTPStubs/OHHTTPStubs.h>
#import "BKRPlayer.h"
#import "BKRPlayableCassette.h"
#import "BKRPlayableRawFrame.h"
#import "BKRPlayableScene.h"

@interface BKRPlayer ()
@property (nonatomic) dispatch_queue_t playingQueue;
@property (nonatomic, copy) NSString *playheadUniqueIdentifier;
@end

@implementation BKRPlayer

- (instancetype)init {
    self = [super init];
    if (self) {
        _playingQueue = dispatch_queue_create("com.BKR.playing", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    dispatch_barrier_sync(self.playingQueue, ^{
        _enabled = enabled;
    });
    if (_enabled) {
        NSLog(@"implement player");
    } else {
        [self reset];
    }
}

- (void)reset {
    if (_enabled) {
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
            return NO;
        } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
            return nil;
        }];
    } else {
        [OHHTTPStubs removeAllStubs];
    }
}

- (void)setCurrentCassette:(BKRPlayableCassette *)currentCassette {
    if (currentCassette) {
        // This is for debugging purposes
        NSParameterAssert([currentCassette isKindOfClass:[BKRPlayableCassette class]]);
    }
    dispatch_barrier_sync(self.playingQueue, ^{
        _currentCassette = currentCassette;
    });
}

@end
