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
    NSArray<BKRFrame *> *unorderedFrames = [self _unorderedFrames];
    __block NSArray<BKRFrame *> *orderedFrames = nil;
    dispatch_sync(self.accessingQueue, ^{
        orderedFrames = [unorderedFrames sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:BKRKey(BKRFrame *, creationDate) ascending:YES]]];
    });
    return orderedFrames;
//    return [[self _unorderedFrames] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:BKRKey(BKRFrame *, creationDate) ascending:YES]]];
}

- (NSArray<BKRFrame *> *)_unorderedFrames {
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
    return (NSArray<BKRRequestFrame *> *)[self.allFrames filteredArrayUsingPredicate:[self _predicateForFramesOfClass:[BKRRequestFrame class]]];
}

- (NSArray<BKRResponseFrame *> *)allResponseFrames {
    return (NSArray<BKRResponseFrame *> *)[self.allFrames filteredArrayUsingPredicate:[self _predicateForFramesOfClass:[BKRResponseFrame class]]];
}

- (NSArray<BKRDataFrame *> *)allDataFrames {
    return (NSArray<BKRDataFrame *> *)[self.allFrames filteredArrayUsingPredicate:[self _predicateForFramesOfClass:[BKRDataFrame class]]];
}

- (NSArray<BKRErrorFrame *> *)allErrorFrames {
    return (NSArray<BKRErrorFrame *> *)[self.allFrames filteredArrayUsingPredicate:[self _predicateForFramesOfClass:[BKRErrorFrame class]]];
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

- (NSPredicate *)_predicateForFramesOfClass:(Class)frameClass {
    return [NSPredicate predicateWithFormat:@"class == %@", frameClass];
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
