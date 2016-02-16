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
#import "BKRRawFrame+Recordable.h"
#import "BKROHHTTPStubsWrapper.h"
#import "BKRScene+Recordable.h"
#import "BKRNSURLSessionSwizzling.h"

@interface BKRRecorder ()
@property (nonatomic, strong) BKRRecordingEditor *editor;
@end

@implementation BKRRecorder
@synthesize beginRecordingBlock = _beginRecordingBlock;
@synthesize endRecordingBlock = _endRecordingBlock;

- (instancetype)init {
    self = [super init];
    if (self) {
        [BKRNSURLSessionSwizzling swizzleForRecording];
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

- (NSDictionary *)plistDictionary {
    return self.editor.plistDictionary;
}

- (void)setCurrentCassette:(BKRRecordableCassette *)currentCassette {
    self.editor.currentCassette = currentCassette;
}

- (BKRRecordableCassette *)currentCassette {
    return (BKRRecordableCassette *)self.editor.currentCassette;
}

- (NSArray<BKRScene *> *)allScenes {
    return self.editor.allScenes;
}

- (void)setEnabled:(BOOL)enabled {
    [self setEnabled:enabled withCompletionHandler:nil];
}

- (void)setEnabled:(BOOL)enabled withCompletionHandler:(void (^)(void))completionBlock {
    [self.editor setEnabled:enabled withCompletionHandler:^(BOOL updatedEnabled, BKRCassette *cassette) {
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }
    }];
}

- (BOOL)isEnabled {
    return self.editor.isEnabled;
}

- (BOOL)didRecord {
    return self.editor.handledRecording;
}

- (void)resetWithCompletionBlock:(void (^)(void))completionBlock {
    self.currentCassette = nil;
    self.beginRecordingBlock = nil;
    self.endRecordingBlock = nil;
    [self.editor reset];
    [self.editor editCassette:^(BOOL updatedEnabled, BKRCassette *cassette) {
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }
    }];
}

#pragma mark - BKRVCRRecording

- (void)setBeginRecordingBlock:(BKRBeginRecordingTaskBlock)beginRecordingBlock {
    self.editor.beginRecordingBlock = beginRecordingBlock;
}

- (BKRBeginRecordingTaskBlock)beginRecordingBlock {
    return self.editor.beginRecordingBlock;
}

- (void)setEndRecordingBlock:(BKREndRecordingTaskBlock)endRecordingBlock {
    self.editor.endRecordingBlock = endRecordingBlock;
}

- (BKREndRecordingTaskBlock)endRecordingBlock {
    return self.editor.endRecordingBlock;
}

#pragma mark - NSURLSession recording

- (void)beginRecording:(NSURLSessionTask *)task {
    [self.editor executeBeginRecordingBlockWithTask:task];
}

- (void)recordTask:(NSURLSessionTask *)task didFinishWithError:(NSError *)arg1 {
    [self.editor executeEndRecordingBlockWithTask:task];
}

- (void)recordTask:(NSURLSessionTask *)task redirectRequest:(NSURLRequest *)arg1 redirectResponse:(NSURLResponse *)arg2 {
    if (!self.enabled) {
        return;
    }
}

- (void)initTask:(NSURLSessionTask *)task {
    BKRRawFrame *requestFrame = [BKRRawFrame frameWithTask:task];
    requestFrame.item = task.originalRequest;
    [self.editor addFrame:requestFrame];
}

- (void)recordTask:(NSURLSessionTask *)task didReceiveData:(NSData *)data {
    BKRRawFrame *dataFrame = [BKRRawFrame frameWithTask:task];
    dataFrame.item = data.copy;
    [self.editor addFrame:dataFrame];
}

- (void)recordTask:(NSURLSessionTask *)task didReceiveResponse:(NSURLResponse *)response {
    BKRRawFrame *currentRequestFrame = [BKRRawFrame frameWithTask:task];
    currentRequestFrame.item = task.currentRequest;
    [self.editor addFrame:currentRequestFrame];
    
    BKRRawFrame *responseFrame = [BKRRawFrame frameWithTask:task];
    responseFrame.item = response;
    [self.editor addFrame:responseFrame];
}

- (void)recordTask:(NSString *)taskUniqueIdentifier setError:(NSError *)error {
    if (error) {
        BKRRawFrame *errorFrame = [BKRRawFrame frameWithIdentifier:taskUniqueIdentifier];
        errorFrame.item = error;
        [self.editor addFrame:errorFrame];
    }
}

@end
