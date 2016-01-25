//
//  BKRRecorder.m
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import "BKRRecorder.h"
#import "BKRRecordableCassette.h"
#import "BKRRecordableRawFrame.h"
#import "BKROHHTTPStubsWrapper.h"

@interface BKRRecorder ()
@property (nonatomic) dispatch_queue_t recordingQueue;
@property (nonatomic) NSDate *currentRecordingStartTime;

@end

@implementation BKRRecorder

- (instancetype)init {
    self = [super init];
    if (self) {
        _recordingQueue = dispatch_queue_create("com.BKR.recorderQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

+ (instancetype)sharedInstance {
    static BKRRecorder *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BKRRecorder alloc] init];
    });
    return sharedInstance;
}

// maybe set a date flag and ignore things after that flag??
- (void)reset {
    if (_enabled) {
        self.currentRecordingStartTime = [NSDate date];
    } else {
        self.currentRecordingStartTime = nil;
    }
}

- (void)setCurrentCassette:(BKRRecordableCassette *)currentCassette {
    if (currentCassette) {
        // This is for debugging purposes
        NSParameterAssert([currentCassette isKindOfClass:[BKRRecordableCassette class]]);
    }
    dispatch_barrier_sync(self.recordingQueue, ^{
        _currentCassette = currentCassette;
    });
    [self reset];
}

- (void)setEnabled:(BOOL)enabled {
    dispatch_barrier_sync(self.recordingQueue, ^{
        _enabled = enabled;
    });
    [self reset];
    if (_enabled) {
        [BKROHHTTPStubsWrapper removeAllStubs];
    }
}

#pragma mark - NSURLSession recording

- (void)recordTask:(NSURLSessionTask *)task redirectRequest:(NSURLRequest *)arg1 redirectResponse:(NSURLResponse *)arg2 {
    if (!self.enabled) {
        return;
    }
    
}

- (void)initTask:(NSURLSessionTask *)task {
    if (!self.enabled) {
        return;
    }
    __typeof (self) wself = self;
    dispatch_async(self.recordingQueue, ^{
        __typeof (wself) sself = wself;
        if (!sself.currentRecordingStartTime) {
            return;
        }
        BKRRecordableRawFrame *requestFrame = [BKRRecordableRawFrame frameWithTask:task];
        requestFrame.item = task.originalRequest;
        [sself.currentCassette addFrame:requestFrame];
    });
}

//- (void)recordTaskResumption:(NSURLSessionTask *)task {
//    if (!self.enabled) {
//        return;
//    }
//    __typeof (self) wself = self;
//    dispatch_async(self.recordingQueue, ^{
//        __typeof (wself) sself = wself;
//        BKRRequest *frame = [BKRRequest frameWithTask:task];
//        [frame addRequest:task.originalRequest isOriginal:YES];
//        [sself.currentCassette addFrame:frame];
//    });
//}

- (void)recordTask:(NSURLSessionTask *)task didReceiveData:(NSData *)data {
    if (!self.enabled) {
        return;
    }
    __typeof (self) wself = self;
    dispatch_async(self.recordingQueue, ^{
        __typeof (wself) sself = wself;
        if (!sself.currentRecordingStartTime) {
            return;
        }
        BKRRecordableRawFrame *dataFrame = [BKRRecordableRawFrame frameWithTask:task];
        dataFrame.item = data.copy;
        [sself.currentCassette addFrame:dataFrame];
    });
}

- (void)recordTask:(NSURLSessionTask *)task didReceiveResponse:(NSURLResponse *)response {
    if (!self.enabled) {
        return;
    }
    __typeof (self) wself = self;
    dispatch_async(self.recordingQueue, ^{
        __typeof (wself) sself = wself;
        if (!sself.currentRecordingStartTime) {
            return;
        }
        // after response from server, the currentRequest might not match the original request, let's record that
        // just in case it's important
        BKRRecordableRawFrame *currentRequestFrame = [BKRRecordableRawFrame frameWithTask:task];
        currentRequestFrame.item = task.currentRequest;
        [sself.currentCassette addFrame:currentRequestFrame];
        
        // now add response
        BKRRecordableRawFrame *frame = [BKRRecordableRawFrame frameWithTask:task];
        frame.item = response;
        [sself.currentCassette addFrame:frame];
    });
}

- (void)recordTask:(NSURLSessionTask *)task didFinishWithError:(NSError *)error {
    NSLog(@"^^^^^^^^^^^^^^^^^^^^^ enter finish method");
    if (!self.enabled) {
        return;
    }
    __typeof (self) wself = self;
    dispatch_async(self.recordingQueue, ^{
        __typeof (wself) sself = wself;
        if (!sself.currentRecordingStartTime) {
            return;
        }
        if (error) {
            NSLog(@"^^^^^^^^^^^^^^^^^^^^^ recording error");
            BKRRecordableRawFrame *frame = [BKRRecordableRawFrame frameWithTask:task];
            frame.item = error;
            [sself.currentCassette addFrame:frame];
        }
    });
}

//- (void)recordTaskCancellation:(NSURLSessionTask *)task {
//    if (!self.enabled) {
//        return;
//    }
//    __typeof (self) wself = self;
//    dispatch_async(self.recordingQueue, ^{
//        __typeof (wself) sself = wself;
////        JSZVCRRecording *recording = [sself storedRecordingFromTask:task];
////        recording.cancelled = YES;
//        BKRScene *scene = [BKRScene sceneWithTask:task];
//        
//    });
//}

@end
