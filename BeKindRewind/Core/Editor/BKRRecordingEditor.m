//
//  BKRRecordingEditor.m
//  Pods
//
//  Created by Jordan Zucker on 1/29/16.
//
//

#import "BKRRecordingEditor.h"
#import "BKRRecordableCassette.h"
#import "BKRRecordableRawFrame.h"

@interface BKRRecordingEditor ()
@property (nonatomic, assign, readwrite) BOOL handledRecording;

@end

@implementation BKRRecordingEditor

@synthesize recordingStartTime = _recordingStartTime;

- (instancetype)init {
    self = [super init];
    if (self) {
        _handledRecording = NO;
    }
    return self;
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

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self updateRecordingStartTime];
}

- (void)addFrame:(BKRRecordableRawFrame *)frame {
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

- (BOOL)_shouldRecord:(BKRRecordableRawFrame *)rawFrame {
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

- (void)executeEndRecordingBlock:(BKREndRecordingTaskBlock)endRecordingBlock withTask:(NSURLSessionTask *)task {
    __block BKRRecordableCassette *cassette = (BKRRecordableCassette *)self.currentCassette;
    dispatch_barrier_async(self.editingQueue, ^{
        [cassette executeEndTaskRecordingBlock:endRecordingBlock withTask:task];
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

@end
