//
//  BKRScene.m
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import "BKRScene.h"
#import "BKRFrame.h"
#import "BKRDataFrame.h"
#import "BKRRequestFrame.h"
#import "BKRResponseFrame.h"
#import "BKRRawFrame.h"
#import "BKRErrorFrame.h"
#import "BKRConstants.h"

@interface BKRScene ()
@property (nonatomic, strong) NSMutableArray<BKRFrame *> *frames;
@property (nonatomic) dispatch_queue_t accessingQueue;
@end


@implementation BKRScene

- (instancetype)init {
    self = [super init];
    if (self) {
        _frames = [NSMutableArray array];
        _accessingQueue = dispatch_queue_create("com.BKRScene.accessingQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (BKRFrame *)clapboardFrame {
    return self.allFrames.firstObject;
}

- (NSArray<BKRFrame *> *)allFrames {
    return [[self unorderedFrames] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:BKRKey(BKRFrame *, creationDate) ascending:YES]]];
}

- (NSArray<BKRFrame *> *)unorderedFrames {
    __block NSArray<BKRFrame *> *currentFramesArray = nil;
    __weak typeof(self) wself = self;
    dispatch_sync(self.accessingQueue, ^{
        __strong typeof(wself) sself = wself;
        currentFramesArray = sself->_frames.copy;
    });
    return currentFramesArray;
}

- (void)addFrameToFramesArray:(BKRFrame *)frame {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.accessingQueue, ^{
        __strong typeof(wself) sself = wself;
        [sself->_frames addObject:frame];
    });
}

- (NSArray<BKRRequestFrame *> *)allRequestFrames {
    return [self _framesOnlyOfType:[BKRRequestFrame class]];
}

- (NSArray<BKRResponseFrame *> *)allResponseFrames {
    return [self _framesOnlyOfType:[BKRResponseFrame class]];
}

- (NSArray<BKRDataFrame *> *)allDataFrames {
    return [self _framesOnlyOfType:[BKRDataFrame class]];
}

- (NSArray<BKRErrorFrame *> *)allErrorFrames {
    return [self _framesOnlyOfType:[BKRErrorFrame class]];
}

- (BKRRequestFrame *)originalRequest {
    return self.allRequestFrames.firstObject;
}

- (BKRRequestFrame *)currentRequest {
    if (self.allRequestFrames.count > 1) {
        return [self.allRequestFrames objectAtIndex:1];
    }
    return nil;
}

- (NSArray *)_framesOnlyOfType:(Class)frameClass {
    NSMutableArray *restrictedFrames = [NSMutableArray array];
    for (BKRFrame *frame in self.allFrames) {
        if ([frame isKindOfClass:frameClass]) {
            [restrictedFrames addObject:frame];
        } else {
            continue;
        }
    }
    return restrictedFrames.copy;
}

@end
