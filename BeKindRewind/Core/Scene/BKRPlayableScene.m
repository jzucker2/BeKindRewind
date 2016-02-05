//
//  BKRPlayableScene.m
//  Pods
//
//  Created by Jordan Zucker on 1/21/16.
//
//

#import "BKRPlayableScene.h"
#import "BKRPlayableRawFrame.h"
#import "BKRResponseFrame.h"
#import "BKRErrorFrame.h"
#import "BKRDataFrame.h"

// remove, only here for testing
#import "BKRRequestFrame.h"

@interface BKRPlayableScene ()
//@property (nonatomic, strong) NSMutableArray<BKRPlayableRawFrame *> *frames;
@end

@implementation BKRPlayableScene
//@synthesize frames = _frames;

- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary {
    NSParameterAssert(dictionary);
    self = [super init];
    if (self) {
        self.uniqueIdentifier = dictionary[@"uniqueIdentifier"];
//        _frames = [self _editedFrames:dictionary[@"frames"]];
        [self _addEditedFrames:dictionary[@"frames"]];
    }
    return self;
}

- (void)_addEditedFrames:(NSArray<NSDictionary *> *)rawFrames {
    __weak typeof(self) wself = self;
    dispatch_queue_t editingQueue = dispatch_queue_create("com.BKRPlayableScene.editingQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_apply(rawFrames.count, editingQueue, ^(size_t iteration) {
        __strong typeof(wself) sself = wself;
        BKRPlayableRawFrame *rawFrame = [[BKRPlayableRawFrame alloc] initFromPlistDictionary:rawFrames[iteration]];
        [sself addFrameToFramesArray:rawFrame.editedFrame];
    });
}

- (NSData *)responseData {
    BKRDataFrame *dataFrame = self.allDataFrames.firstObject;
    return dataFrame.rawData;
}

- (NSInteger)responseStatusCode {
    BKRResponseFrame *responseFrame = self.allResponseFrames.firstObject;
    return responseFrame.statusCode;
}

- (NSDictionary *)responseHeaders {
    BKRResponseFrame *responseFrame = self.allResponseFrames.firstObject;
    return responseFrame.allHeaderFields;
}

- (NSError *)responseError {
    BKRErrorFrame *responseFrame = self.allErrorFrames.firstObject;
    return responseFrame.error;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%p>: request: %@", self, self.originalRequest.URL];
}

@end
