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

@implementation BKRRecordingEditor

@synthesize recordingStartTime = _recordingStartTime;

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

- (void)executeEndRecordingBlock:(BKREndRecordingTaskBlock)endRecordingBlock withTask:(NSURLSessionTask *)task {
    __block BKRRecordableCassette *cassette = (BKRRecordableCassette *)self.currentCassette;
    dispatch_barrier_async(self.editingQueue, ^{
        [cassette executeEndTaskRecordingBlock:endRecordingBlock withTask:task];
    });
}

@end
