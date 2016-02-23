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
    BKRWeakify(self);
    dispatch_sync(self.editingQueue, ^{
        BKRStrongify(self);
        recordingTime = self->_recordingStartTime;
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
    NSLog(@"%@ addFrame: %@", self, frame.debugDescription);
    [self editCassette:^(BOOL updatedEnabled, BKRCassette *cassette) {
        BKRStrongify(self);
        if (!cassette) {
            NSLog(@"%@ has no cassette right now", NSStringFromClass(self.class));
            return;
        }
        NSLog(@"%@ see if you can record", self);
        if (![self _shouldRecord:frame]) {
            return;
        }
        self->_handledRecording = YES;
        NSLog(@"%@: should record YES add frame to cassette %@", self, frame.debugDescription);
        [cassette addFrame:frame];
    }];
}

- (BOOL)_shouldRecord:(BKRRawFrame *)rawFrame {
    if (
        !self->_recordingStartTime ||
        !rawFrame
        ) {
        NSLog(@"%@: don't record frame because no recording start time or rawFrame is nil: %@", self, rawFrame.debugDescription);
        return NO;
    }
    NSLog(@"%@: for frame (%@) comparing frame creation date (%@) with recording start time (%@)", self, rawFrame.debugDescription, rawFrame.creationDate, self->_recordingStartTime);
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
    NSLog(@"%@ (plistDictionary): start of edit synchronously", self);
    [self editCassetteSynchronously:^(BOOL updatedEnabled, BKRCassette *cassette) {
        NSLog(@"%@ (plistDictionary): start of synch block", self);
        dictionary = cassette.plistDictionary;
        NSLog(@"%@ (plistDictionary): end of getting plist dict in synch block", self);
    }];
    NSLog(@"%@ (plistDictionary): now return dictionary", self);
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
