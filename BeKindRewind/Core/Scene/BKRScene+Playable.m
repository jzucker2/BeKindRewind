//
//  BKRScene+Playable.m
//  Pods
//
//  Created by Jordan Zucker on 2/12/16.
//
//

#import "BKRScene+Playable.h"
#import "BKRRawFrame+Playable.h"
#import "BKRResponseFrame.h"
#import "BKRErrorFrame.h"
#import "BKRDataFrame.h"
#import "BKRRequestFrame.h"
#import "BKRConstants.h"

@implementation BKRScene (Playable)

- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary {
    NSParameterAssert(dictionary);
    self = [self init];
    if (self) {
        self.uniqueIdentifier = dictionary[@"uniqueIdentifier"];
        [self _addEditedFrames:dictionary[@"frames"]];
    }
    return self;
}

- (void)_addEditedFrames:(NSArray<NSDictionary *> *)rawFrames {
    BKRWeakify(self);
    dispatch_queue_t editingQueue = dispatch_queue_create("com.BKRPlayableScene.editingQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_apply(rawFrames.count, editingQueue, ^(size_t iteration) {
        BKRStrongify(self);
        BKRRawFrame *rawFrame = [[BKRRawFrame alloc] initFromPlistDictionary:rawFrames[iteration]];
        [self addFrameToFramesArray:rawFrame.editedPlaying];
    });
}

- (NSData *)responseData {
//#warning this needs to be fixed for chunked replay
//    BKRDataFrame *dataFrame = self.allDataFrames.firstObject;
    NSMutableData *responseData = [NSMutableData data];
    for (BKRDataFrame *dataFrame in self.allDataFrames) {
        [responseData appendData:dataFrame.rawData];
    }
    return responseData.copy;
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
