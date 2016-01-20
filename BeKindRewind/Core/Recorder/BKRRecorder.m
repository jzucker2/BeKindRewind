//
//  BKRRecorder.m
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import "BKRRecorder.h"
#import "BKRCassette.h"
#import "BKRRawFrame.h"
//#import "BKRData.h"
//#import "BKRResponse.h"
//#import "BKRRequest.h"
//#import "BKRError.h"

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

- (void)setCurrentCassette:(BKRCassette *)currentCassette {
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
//        BKRRequest *frame = [BKRRequest frameWithTask:task];
//        [frame addRequest:task.originalRequest isOriginal:YES];
//        [sself.currentCassette addFrame:frame];
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
//        BKRData *frame = [BKRData frameWithTask:task];
//        [frame addData:data];
//        [sself.currentCassette addFrame:frame];
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
//        BKRRequest *currentRequest = [BKRRequest frameWithTask:task];
//        [currentRequest addRequest:task.currentRequest];
//        [sself.currentCassette addFrame:currentRequest];
        BKRRawFrame *currentRequestFrame = [BKRRawFrame frameWithTask:task];
        currentRequestFrame.item = task.currentRequest;
        [sself.currentCassette addFrame:currentRequestFrame];
        
        // now add response
//        BKRResponse *frame = [BKRResponse frameWithTask:task];
//        [frame addResponse:response];
//        [sself.currentCassette addFrame:frame];
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
//            BKRError *frame = [BKRError frameWithTask:task];
//            [frame addError:error];
//            [sself.currentCassette addFrame:frame];
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
