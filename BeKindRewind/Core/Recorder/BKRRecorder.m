//
//  BKRRecorder.m
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import "BKRRecorder.h"
#import "BKRRecordableCassette.h"
#import "BKRRawFrame.h"

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
    _recordingQueue = dispatch_queue_create("com.BKR.recorderQueue", DISPATCH_QUEUE_SERIAL);
}

- (void)setCurrentCassette:(BKRRecordableCassette *)currentCassette {
    if (currentCassette) {
        // This is for debugging purposes
        NSAssert([currentCassette isKindOfClass:[BKRRecordableCassette class]], @"Must be a recordable class, not just a regular BKRCassette, you tried to use: %@", NSStringFromClass(currentCassette.class));
    }
    _currentCassette = currentCassette;
    [self reset];
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
        BKRRawFrame *requestFrame = [BKRRawFrame frameWithTask:task];
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
        BKRRawFrame *dataFrame = [BKRRawFrame frameWithTask:task];
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
        // after response from server, the currentRequest might not match the original request, let's record that
        // just in case it's important
        BKRRawFrame *currentRequestFrame = [BKRRawFrame frameWithTask:task];
        currentRequestFrame.item = task.currentRequest;
        [sself.currentCassette addFrame:currentRequestFrame];
        
        // now add response
        BKRRawFrame *frame = [BKRRawFrame frameWithTask:task];
        frame.item = response;
        [sself.currentCassette addFrame:frame];
    });
}

- (void)recordTask:(NSURLSessionTask *)task didFinishWithError:(NSError *)error {
    if (!self.enabled) {
        return;
    }
    __typeof (self) wself = self;
    dispatch_async(self.recordingQueue, ^{
        __typeof (wself) sself = wself;
        if (error) {
            BKRRawFrame *frame = [BKRRawFrame frameWithTask:task];
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
