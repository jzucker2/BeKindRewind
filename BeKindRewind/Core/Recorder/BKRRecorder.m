//
//  BKRRecorder.m
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import "BKRRecordingEditor.h"
#import "BKRRecorder.h"
#import "BKRRecordableCassette.h"
#import "BKRRecordableRawFrame.h"
#import "BKROHHTTPStubsWrapper.h"
#import "BKRRecordableScene.h"

@interface BKRRecorder ()
@property (nonatomic, strong) BKRRecordingEditor *editor;
@end

@implementation BKRRecorder

- (instancetype)init {
    self = [super init];
    if (self) {
        _editor = [BKRRecordingEditor editor];
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

- (void)setCurrentCassette:(BKRRecordableCassette *)currentCassette {
    self.editor.currentCassette = currentCassette;
}

- (BKRRecordableCassette *)currentCassette {
    return (BKRRecordableCassette *)self.editor.currentCassette;
}

- (NSArray<BKRRecordableScene *> *)allScenes {
    return (NSArray<BKRRecordableScene *> *)self.currentCassette.allScenes;
}

- (void)setEnabled:(BOOL)enabled {
    self.editor.enabled = enabled;
}

- (BOOL)isEnabled {
    return self.editor.isEnabled;
}

- (void)reset {
    [self.editor updateRecordingStartTime];
}

#pragma mark - NSURLSession recording

- (void)recordTask:(NSURLSessionTask *)task redirectRequest:(NSURLRequest *)arg1 redirectResponse:(NSURLResponse *)arg2 {
    if (!self.enabled) {
        return;
    }
    
}

- (void)initTask:(NSURLSessionTask *)task {

    BKRRecordableRawFrame *requestFrame = [BKRRecordableRawFrame frameWithTask:task];
    requestFrame.item = task.originalRequest;
    [self.editor addFrame:requestFrame];
}

- (void)recordTask:(NSURLSessionTask *)task didReceiveData:(NSData *)data {
    BKRRecordableRawFrame *dataFrame = [BKRRecordableRawFrame frameWithTask:task];
    dataFrame.item = data.copy;
    [self.editor addFrame:dataFrame];
}

- (void)recordTask:(NSURLSessionTask *)task didReceiveResponse:(NSURLResponse *)response {
    BKRRecordableRawFrame *currentRequestFrame = [BKRRecordableRawFrame frameWithTask:task];
    currentRequestFrame.item = task.currentRequest;
    [self.editor addFrame:currentRequestFrame];
    
    BKRRecordableRawFrame *responseFrame = [BKRRecordableRawFrame frameWithTask:task];
    responseFrame.item = response;
    [self.editor addFrame:responseFrame];
}

- (void)recordTask:(NSString *)taskUniqueIdentifier setError:(NSError *)error {
    if (error) {
        BKRRecordableRawFrame *errorFrame = [BKRRecordableRawFrame frameWithIdentifier:taskUniqueIdentifier];
        errorFrame.item = error;
        [self.editor addFrame:errorFrame];
    }
}

@end
