//
//  BKRRecordingEditor.m
//  Pods
//
//  Created by Jordan Zucker on 1/29/16.
//
//

#import "BKRRecordingEditor.h"
#import "BKRRecordableCassette.h"
#import "BKRRawFrame+Recordable.h"

@interface BKRRecordingEditor ()
@property (nonatomic, assign, readwrite) BOOL handledRecording;

@end

@implementation BKRRecordingEditor

@synthesize recordingStartTime = _recordingStartTime;
@synthesize beginRecordingBlock = _beginRecordingBlock;
@synthesize endRecordingBlock = _endRecordingBlock;

- (instancetype)init {
    self = [super init];
    if (self) {
        _handledRecording = NO;
    }
    return self;
}

- (void)resetHandledRecording {
    BKRWeakify(self);
    dispatch_barrier_async(self.editingQueue, ^{
        BKRStrongify(self);
        self->_handledRecording = NO;
    });
}

- (NSDate *)recordingStartTime {
    __block NSDate *recordingTime = nil;
    __weak typeof(self) wself = self;
    dispatch_sync(self.editingQueue, ^{
        __strong typeof(wself) sself = wself;
        recordingTime = sself->_recordingStartTime;
    });
    return recordingTime;
}

- (void)setRecordingStartTime:(NSDate *)recordingStartTime {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.editingQueue, ^{
        __strong typeof(wself) sself = wself;
        sself->_recordingStartTime = recordingStartTime;
    });
}

- (void)updateRecordingStartTime {
    if (self.isEnabled) {
        self.recordingStartTime = [NSDate date];
    } else {
        self.recordingStartTime = nil;
    }
}

- (void)setEnabled:(BOOL)enabled withCompletionHandler:(void (^)(void))completionBlock {
    [super setEnabled:enabled withCompletionHandler:nil];
    [self updateRecordingStartTime];
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

- (void)setEnabled:(BOOL)enabled {
    [self setEnabled:enabled withCompletionHandler:nil];
}

- (void)addFrame:(BKRRawFrame *)frame {
    __block BKRRecordableCassette *cassette = (BKRRecordableCassette *)self.currentCassette;
    if (!cassette) {
        NSLog(@"%@ has no cassette right now", NSStringFromClass(self.class));
        return;
    }
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.editingQueue, ^{
        __strong typeof(wself) sself = wself;
        if (![sself _shouldRecord:frame]) {
            return;
        }
        sself->_handledRecording = YES;
        [cassette addFrame:frame];
    });
}

- (BOOL)_shouldRecord:(BKRRawFrame *)rawFrame {
    if (
        !self->_recordingStartTime ||
        !rawFrame
        ) {
        return NO;
    }
    return [rawFrame.creationDate compare:self->_recordingStartTime];
}

- (BOOL)handledRecording {
    __block BOOL currentHandledRecording;
    __weak typeof(self) wself = self;
    dispatch_sync(self.editingQueue, ^{
        __strong typeof(wself) sself = wself;
        currentHandledRecording = sself->_handledRecording;
    });
    return currentHandledRecording;
}

- (void)executeBeginRecordingBlockWithTask:(NSURLSessionTask *)task {
    // need this to be synchronous on the main queue
    BKRBeginRecordingTaskBlock currentBeginRecordingBlock = self.beginRecordingBlock;
    if (currentBeginRecordingBlock) {
        if ([NSThread isMainThread]) {
            currentBeginRecordingBlock(task);
        } else {
            // if recorder was called from a background queue, then make sure this is called on the main queue
            dispatch_async(dispatch_get_main_queue(), ^{
                currentBeginRecordingBlock(task);
            });
        }
    }
}

- (void)executeEndRecordingBlockWithTask:(NSURLSessionTask *)task {
    __block BKRRecordableCassette *cassette = (BKRRecordableCassette *)self.currentCassette;
    BKREndRecordingTaskBlock currentEndRecordingTaskBlock = self.endRecordingBlock;
    if (!currentEndRecordingTaskBlock) {
        return;
    }
    dispatch_barrier_async(self.editingQueue, ^{
        [cassette executeEndTaskRecordingBlock:currentEndRecordingTaskBlock withTask:task];
    });
}

- (NSDictionary *)plistDictionary {
    __block NSDictionary *dictionary = nil;
    BKRRecordableCassette *cassette = (BKRRecordableCassette *)self.currentCassette;
    // this is dispatch sync so that it occurs after any queued writes (adding frames)
    dispatch_barrier_sync(self.editingQueue, ^{
        dictionary = cassette.plistDictionary;
    });
    return dictionary;
}

#pragma mark - BKRVCRRecording

- (void)setBeginRecordingBlock:(BKRBeginRecordingTaskBlock)beginRecordingBlock {
    dispatch_barrier_async(self.editingQueue, ^{
        self->_beginRecordingBlock = beginRecordingBlock;
    });
}

- (BKRBeginRecordingTaskBlock)beginRecordingBlock {
    __block BKRBeginRecordingTaskBlock recordingBlock = nil;
    dispatch_sync(self.editingQueue, ^{
        recordingBlock = self->_beginRecordingBlock;
    });
    return recordingBlock;
}

- (void)setEndRecordingBlock:(BKREndRecordingTaskBlock)endRecordingBlock {
    dispatch_barrier_async(self.editingQueue, ^{
        self->_endRecordingBlock = endRecordingBlock;
    });
}

- (BKREndRecordingTaskBlock)endRecordingBlock {
    __block BKREndRecordingTaskBlock recordingBlock = nil;
    dispatch_sync(self.editingQueue, ^{
        recordingBlock = self->_endRecordingBlock;
    });
    return recordingBlock;
}


@end
