//
//  BKRRecorder.m
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import "BKRRecordingEditor.h"
#import "BKRConstants.h"
#import "BKRRecorder.h"
#import "BKROHHTTPStubsWrapper.h"
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
        _editor = [BKRRecordingEditor editorWithConfiguration:nil];
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

- (void)setCurrentCassette:(BKRCassette *)currentCassette {
    self.editor.currentCassette = currentCassette;
}

- (BKRCassette *)currentCassette {
    return self.editor.currentCassette;
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
            completionBlock();
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
    [self.editor resetWithCompletionBlock:^{
        if (completionBlock) {
            completionBlock();
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
    // add the original request
    [self.editor addItem:task.originalRequest forTask:task withContext:BKRRecordingContextBeginning];
}

- (void)recordTask:(NSURLSessionTask *)task didFinishWithError:(NSError *)error {
    [self.editor executeEndRecordingBlockWithTask:task];
}

- (void)recordTask:(NSURLSessionTask *)task redirectRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    // protect from possibly being nil
    NSMutableDictionary *addItemDict = [NSMutableDictionary dictionary];
    if (request) {
        addItemDict[kBKRRedirectRequestKey] = request;
    }
    if (response) {
        addItemDict[kBKRRedirectResponseKey] = response;
    }
    if (addItemDict.allKeys.count) {
        [self.editor addItem:addItemDict.copy forTask:task withContext:BKRRecordingContextRedirecting];
    }
}

- (void)recordTask:(NSURLSessionTask *)task didReceiveData:(NSData *)data {
    [self.editor addItem:data forTask:task withContext:BKRRecordingContextExecuting];
}

- (void)recordTask:(NSURLSessionTask *)task didReceiveResponse:(NSURLResponse *)response {
    [self.editor addItem:response.copy forTask:task withContext:BKRRecordingContextExecuting];
}

- (void)recordTask:(NSURLSessionTask *)task didAddCurrentRequest:(NSURLRequest *)request {
    [self.editor addItem:request forTask:task withContext:BKRRecordingContextAddingCurrentRequest];
}

- (void)recordTask:(NSURLSessionTask *)task setError:(NSError *)error {
    if (error) {
        [self.editor addItem:error forTask:task withContext:BKRRecordingContextExecuting];
    }
}

@end
