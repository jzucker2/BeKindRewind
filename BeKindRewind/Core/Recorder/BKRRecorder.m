//
//  BKRRecorder.m
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import "BKRCassetteHandler.h"
#import "BKRRecorder.h"
#import "BKRRecordableCassette.h"
#import "BKRRecordableRawFrame.h"
#import "BKROHHTTPStubsWrapper.h"
#import "BKRRecordableScene.h"

@interface BKRRecorder ()
//@property (nonatomic) dispatch_queue_t recordingQueue;
@property (nonatomic) NSDate *currentRecordingStartTime;
@property (nonatomic) BKRCassetteHandler *cassetteHandler;
@property (nonatomic) dispatch_queue_t recordingQueue;

@end

@implementation BKRRecorder
@synthesize currentRecordingStartTime = _currentRecordingStartTime;

- (instancetype)init {
    self = [super init];
    if (self) {
//        _recordingQueue = dispatch_queue_create("com.BKR.recorderQueue", DISPATCH_QUEUE_CONCURRENT);
        _cassetteHandler = [BKRCassetteHandler handler];
        _recordingQueue = dispatch_queue_create("com.BKR.recordingQueue", DISPATCH_QUEUE_CONCURRENT);
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

//- (void)setCassette:(BKRRecordableCassette *)cassette {
//    self.currentCassette = cassette;
//}

- (void)setCurrentCassette:(BKRRecordableCassette *)currentCassette {
    self.cassetteHandler.currentCassette = currentCassette;
}

- (BKRRecordableCassette *)currentCassette {
    return (BKRRecordableCassette *)self.cassetteHandler.currentCassette;
}

- (NSArray<BKRRecordableScene *> *)allScenes {
    return (NSArray<BKRRecordableScene *> *)self.currentCassette.allScenes;
}

- (void)setEnabled:(BOOL)enabled {
    self.cassetteHandler.enabled = enabled;
    if (enabled) {
        self.currentRecordingStartTime = [NSDate date];
    } else {
        self.currentRecordingStartTime = nil;
    }
}

- (BOOL)isEnabled {
    return self.cassetteHandler.isEnabled;
}

// maybe set a date flag and ignore things after that flag??
- (void)reset {
//    if (_enabled) {
//        self.currentRecordingStartTime = [NSDate date];
//    } else {
//        self.currentRecordingStartTime = nil;
//    }
    if (self.isEnabled) {
        self.currentRecordingStartTime = [NSDate date];
    } else {
        self.currentRecordingStartTime = nil;
    }
}

//- (void)setCurrentCassette:(BKRRecordableCassette *)currentCassette {
//    if (currentCassette) {
//        // This is for debugging purposes
//        NSParameterAssert([currentCassette isKindOfClass:[BKRRecordableCassette class]]);
//    }
//    dispatch_barrier_sync(self.recordingQueue, ^{
//        _currentCassette = currentCassette;
//    });
//    [self reset];
//}

//- (void)setEnabled:(BOOL)enabled {
//    dispatch_barrier_sync(self.recordingQueue, ^{
//        _enabled = enabled;
//    });
//    [self reset];
//    if (_enabled) {
//        [BKROHHTTPStubsWrapper removeAllStubs];
//    }
//}

- (void)setCurrentRecordingStartTime:(NSDate *)currentRecordingStartTime {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.recordingQueue, ^{
        __strong typeof(wself) sself = wself;
        sself->_currentRecordingStartTime = currentRecordingStartTime;
    });
}

- (NSDate *)currentRecordingStartTime {
    __block NSDate *recordingTime = nil;
    __weak typeof(self) wself = self;
    dispatch_sync(self.recordingQueue, ^{
        __strong typeof(wself) sself = wself;
        recordingTime = sself->_currentRecordingStartTime;
    });
    return recordingTime;
}

#pragma mark - Check time

- (BOOL)_shouldRecord:(BKRRecordableRawFrame *)rawFrame {
    if (
        !self->_currentRecordingStartTime ||
        !rawFrame
        ) {
        return NO;
    }
    return [rawFrame.creationDate compare:self->_currentRecordingStartTime];
}

#pragma mark - NSURLSession recording

- (void)recordTask:(NSURLSessionTask *)task redirectRequest:(NSURLRequest *)arg1 redirectResponse:(NSURLResponse *)arg2 {
    if (!self.enabled) {
        return;
    }
    
}

- (void)initTask:(NSURLSessionTask *)task {
//    if (!self.enabled) {
//        return;
//    }
    __typeof (self) wself = self;
    dispatch_async(self.recordingQueue, ^{
        __typeof (wself) sself = wself;
        // check if task is after recording start time
        BKRRecordableRawFrame *requestFrame = [BKRRecordableRawFrame frameWithTask:task];
        if (![sself _shouldRecord:requestFrame]) {
            return;
        }
        requestFrame.item = task.originalRequest;
        BKRRecordableCassette *cassette = sself.currentCassette;
        [cassette addFrame:requestFrame];
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
//    if (!self.enabled) {
//        return;
//    }
    __typeof (self) wself = self;
    dispatch_async(self.cassetteHandler.processingQueue, ^{
        __typeof (wself) sself = wself;
        BKRRecordableRawFrame *dataFrame = [BKRRecordableRawFrame frameWithTask:task];
        if (![sself _shouldRecord:dataFrame]) {
            return;
        }
        dataFrame.item = data.copy;
        [sself.currentCassette addFrame:dataFrame];
    });
}

- (void)recordTask:(NSURLSessionTask *)task didReceiveResponse:(NSURLResponse *)response {
    if (!self.enabled) {
        return;
    }
    __typeof (self) wself = self;
    dispatch_async(self.cassetteHandler.processingQueue, ^{
        __typeof (wself) sself = wself;
        BKRRecordableRawFrame *currentRequestFrame = [BKRRecordableRawFrame frameWithTask:task];
        if (![sself _shouldRecord:currentRequestFrame]) {
            return;
        }
        // after response from server, the currentRequest might not match the original request, let's record that
        // just in case it's important
        currentRequestFrame.item = task.currentRequest;
        [sself.currentCassette addFrame:currentRequestFrame];
        
        // now add response
        BKRRecordableRawFrame *responseFrame = [BKRRecordableRawFrame frameWithTask:task];
        responseFrame.item = response;
        [sself.currentCassette addFrame:responseFrame];
    });
}

- (void)recordTask:(NSString *)taskUniqueIdentifier setError:(NSError *)error {
    NSLog(@"^^^^^^^^^^^^^^^^^^^^^ enter finish method");
//    if (!self.enabled) {
//        return;
//    }
    __typeof (self) wself = self;
    dispatch_async(self.cassetteHandler.processingQueue, ^{
        __typeof (wself) sself = wself;
        
        if (error) {
            NSLog(@"^^^^^^^^^^^^^^^^^^^^^ recording error");
            BKRRecordableRawFrame *errorFrame = [BKRRecordableRawFrame frameWithIdentifier:taskUniqueIdentifier];
            if (![sself _shouldRecord:errorFrame]) {
                return;
            }
            errorFrame.item = error;
            [sself.currentCassette addFrame:errorFrame];
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
