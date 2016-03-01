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

// This resets the BKRRecordingEditor since it interacts with a
// singleton BKRRecorder. This should be called before
// releasing the instance.
- (void)resetWithCompletionBlock:(void (^)(void))completionBlock {
    BKRWeakify(self);
    [super resetWithCompletionBlock:^void (void){
        BKRStrongify(self);
        self->_handledRecording = NO;
        self->_recordingStartTime = nil;
        if (completionBlock) {
            completionBlock();
        }
    }];
}


- (NSNumber *)recordingStartTime {
    __block NSNumber *recordingTime = nil;
    BKRWeakify(self);
    dispatch_sync(self.editingQueue, ^{
        BKRStrongify(self);
        recordingTime = self->_recordingStartTime;
    });
    return recordingTime;
}

- (void)_updateRecordingStartTimeWithEnabled:(BOOL)currentEnabled {
    if (currentEnabled) {
        self->_recordingStartTime = @([[NSDate date] timeIntervalSince1970]);
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

- (void)addItem:(id)item forTask:(NSURLSessionTask *)task {
    if (
        !item ||
        !task
        ) {
        // don't schedule anything if one piece of data is missing or there's not task
        return;
    }
    BKRWeakify(self);
    [self editCassette:^(BOOL updatedEnabled, BKRCassette *cassette) {
        BKRStrongify(self);
        BKRRawFrame *rawFrame = [BKRRawFrame frameWithTask:task];
        rawFrame.item = item;
        
        // check if you should record first:
        // 1) have a frame to record
        // 2) record starting time exists and is valid for this frame's creationDate
        if (![self _shouldRecord:rawFrame]) {
            return;
        }
        if (!cassette) {
            NSLog(@"%@ has no cassette right now", NSStringFromClass(self.class));
            return;
        }
        self->_handledRecording = YES;
        [cassette addFrame:rawFrame];
    }];
}

- (BOOL)_shouldRecord:(BKRRawFrame *)rawFrame {
    if (
        !self->_recordingStartTime ||
        !rawFrame
        ) {
        return NO;
    }
    // need to ensure that rawFrame.creationDate is not earlier than self->_recordingStartTime
    return ([rawFrame.creationDate compare:self->_recordingStartTime] != NSOrderedAscending);
}

- (BOOL)handledRecording {
    __block BOOL currentHandledRecording;
    BKRWeakify(self);
    dispatch_sync(self.editingQueue, ^{
        BKRStrongify(self);
        currentHandledRecording = self->_handledRecording;
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
