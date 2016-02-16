//
//  BKRRecordingEditor.m
//  Pods
//
//  Created by Jordan Zucker on 1/29/16.
//
//

#import "BKRRecordingEditor.h"
#import "BKRCassette+Recordable.h"
#import "BKRRawFrame+Recordable.h"
#import "BKRConstants.h"

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
        _recordingStartTime = nil;
    }
    return self;
}

- (void)reset {
    BKRWeakify(self);
    dispatch_barrier_async(self.editingQueue, ^{
        BKRStrongify(self);
        self->_handledRecording = NO;
        self->_recordingStartTime = nil;
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

- (void)_updateRecordingStartTimeWithEnabled:(BOOL)currentEnabled {
    if (currentEnabled) {
        self->_recordingStartTime = [NSDate date];
    } else {
        self->_recordingStartTime = nil;
    }
}

- (void)setEnabled:(BOOL)enabled withCompletionHandler:(BKRCassetteEditingBlock)editingBlock {
    BKRWeakify(self);
    [super setEnabled:enabled withCompletionHandler:^void(BOOL updatedEnabled, BKRCassette *cassette) {
        BKRStrongify(self);
        [self _updateRecordingStartTimeWithEnabled:enabled];
        if (editingBlock) {
            editingBlock(updatedEnabled, cassette);
        }
    }];
}

- (void)setEnabled:(BOOL)enabled {
    [self setEnabled:enabled withCompletionHandler:nil];
}

- (void)addFrame:(BKRRawFrame *)frame {
    BKRWeakify(self);
    [self editCassette:^(BOOL updatedEnabled, BKRCassette *cassette) {
        BKRStrongify(self);
        if (!cassette) {
            NSLog(@"%@ has no cassette right now", NSStringFromClass(self.class));
            return;
        }
        if (![self _shouldRecord:frame]) {
            return;
        }
        self->_handledRecording = YES;
        [cassette addFrame:frame];
    }];
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
            NSLog(@"main queue");
            currentBeginRecordingBlock(task);
        } else {
            // if recorder was called from a background queue, then make sure this is called on the main queue
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"schedule on main queue");
                currentBeginRecordingBlock(task);
            });
        }
    }
}

- (void)executeEndRecordingBlockWithTask:(NSURLSessionTask *)task {
    BKRWeakify(self);
    [self editCassette:^(BOOL updatedEnabled, BKRCassette *cassette) {
        BKRStrongify(self);
        BKREndRecordingTaskBlock currentEndRecordingTaskBlock = self->_endRecordingBlock;
        if (
            !cassette ||
            !currentEndRecordingTaskBlock
            ) {
            return;
        }
        [cassette executeEndTaskRecordingBlock:currentEndRecordingTaskBlock withTask:task];
    }];
}

- (NSDictionary *)plistDictionary {
    __block NSDictionary *dictionary = nil;
    // this is dispatch sync so that it occurs after any queued writes (adding frames)
    [self editCassetteSynchronously:^(BOOL updatedEnabled, BKRCassette *cassette) {
        dictionary = cassette.plistDictionary;
    }];
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
