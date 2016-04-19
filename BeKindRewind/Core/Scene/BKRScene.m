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
#import "BKRRedirectFrame.h"
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
    return [[self _unorderedFrames] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:BKRKey(BKRFrame *, creationDate) ascending:YES]]];
}

- (NSArray<BKRFrame *> *)_unorderedFrames {
    __block NSArray<BKRFrame *> *currentFramesArray = nil;
    BKRWeakify(self);
    dispatch_sync(self.accessingQueue, ^{
        BKRStrongify(self);
        currentFramesArray = self->_frames.copy;
    });
    return currentFramesArray;
}

- (void)addFrameToFramesArray:(BKRFrame *)frame {
    BKRWeakify(self);
    dispatch_barrier_async(self.accessingQueue, ^{
        BKRStrongify(self);
        if (!frame) {
            return;
        }
        [self->_frames addObject:frame];
    });
}

- (NSArray<BKRRequestFrame *> *)allRequestFrames {
    NSPredicate *isKindOfClassPredicate = [NSPredicate predicateWithFormat:@"self isKindOfClass: %@", [BKRRequestFrame class]];
    return (NSArray<BKRRequestFrame *> *)[self.allFrames filteredArrayUsingPredicate:isKindOfClassPredicate];
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

- (NSArray<BKRCurrentRequestFrame *> *)allCurrentRequestFrames {
    return (NSArray<BKRCurrentRequestFrame *> *)[self.allFrames filteredArrayUsingPredicate:[self _predicateForFramesOfClass:[BKRCurrentRequestFrame class]]];
}

- (NSArray<BKRRedirectFrame *> *)allRedirectFrames {
    return (NSArray<BKRRedirectFrame *> *)[self.allFrames filteredArrayUsingPredicate:[self _predicateForFramesOfClass:[BKRRedirectFrame class]]];
}

- (BKROriginalRequestFrame *)originalRequest {
    // there should only be a single BKROriginalRequestFrame
    return (BKROriginalRequestFrame *)[self.allRequestFrames filteredArrayUsingPredicate:[self _predicateForFramesOfClass:[BKROriginalRequestFrame class]]].firstObject;
}

- (BKRCurrentRequestFrame *)currentRequest {
    // since current requests are sorted, use the last object in the current requests array
    // this is equivalent to task.currentRequest at the end of the task's lifecycle
    // the first currentRequest frame is the first time the server adjusts the originalRequest
    // or the first redirect request
    return self.allCurrentRequestFrames.lastObject;
}

- (NSPredicate *)_predicateForFramesOfClass:(Class)frameClass {
    return [NSPredicate predicateWithFormat:@"class == %@", frameClass];
}

@end

@implementation NSArray (BKRScene)

- (NSArray<BKRScene *> *)scenesSortedByClapboardFrameCreationDate {
    return [self sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:BKRKey(BKRScene *, clapboardFrame.creationDate) ascending:YES]]];
}

@end
