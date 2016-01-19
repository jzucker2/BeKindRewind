//
//  BKRRecorder.m
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import "BKRRecorder.h"
#import "BKRCassette.h"

@interface BKRRecorder ()
@property (nonatomic) dispatch_queue_t recordingQueue;

@end

@implementation BKRRecorder

- (instancetype)init {
    self = [super init];
    if (self) {
        _recordingQueue = dispatch_queue_create("com.BKR.recorderQueue", DISPATCH_QUEUE_SERIAL);
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

- (void)reset {
    
}

#pragma mark - NSURLSession recording

- (void)recordTask:(NSURLSessionTask *)task redirectRequest:(NSURLRequest *)arg1 redirectResponse:(NSURLResponse *)arg2 {
    if (!self.enabled) {
        return;
    }
    
}

- (void)recordTask:(NSURLSessionTask *)task didReceiveData:(NSData *)data {
    if (!self.enabled) {
        return;
    }
    __typeof (self) wself = self;
    dispatch_async(self.recordingQueue, ^{
        __typeof (wself) sself = wself;
//        JSZVCRRecording *recording = [sself storedRecordingFromTask:task];
//        if (recording.data) {
//            NSLog(@"already had data: %@", recording.data);
//        }
//        recording.data = [JSZVCRData dataWithData:data];
    });
}

- (void)recordTask:(NSURLSessionTask *)task didReceiveResponse:(NSURLResponse *)response {
    if (!self.enabled) {
        return;
    }
    __typeof (self) wself = self;
    dispatch_async(self.recordingQueue, ^{
        __typeof (wself) sself = wself;
//        JSZVCRRecording *recording = [sself storedRecordingFromTask:task];
//        if (recording.response) {
//            NSLog(@"already had response: %@", recording.response);
//        }
//        recording.response = [JSZVCRResponse responseWithResponse:response];
    });
}

- (void)recordTask:(NSURLSessionTask *)task didFinishWithError:(NSError *)error {
    if (!self.enabled) {
        return;
    }
    __typeof (self) wself = self;
    dispatch_async(self.recordingQueue, ^{
        __typeof (wself) sself = wself;
//        JSZVCRRecording *recording = [sself storedRecordingFromTask:task];
//        if (error) {
//            recording.error = [JSZVCRError errorWithError:error];
//        }
    });
}

- (void)recordTaskCancellation:(NSURLSessionTask *)task {
    if (!self.enabled) {
        return;
    }
    __typeof (self) wself = self;
    dispatch_async(self.recordingQueue, ^{
        __typeof (wself) sself = wself;
//        JSZVCRRecording *recording = [sself storedRecordingFromTask:task];
//        recording.cancelled = YES;
    });
}

@end
