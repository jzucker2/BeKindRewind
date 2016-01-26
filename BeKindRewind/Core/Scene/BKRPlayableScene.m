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

@interface BKRPlayableScene ()
@end

@implementation BKRPlayableScene

- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary {
    NSParameterAssert(dictionary);
    self = [super init];
    if (self) {
        self.uniqueIdentifier = dictionary[@"uniqueIdentifier"];
        self.frames = [self _editedFrames:dictionary[@"frames"]];
    }
    return self;
}

- (NSArray<BKRFrame *> *)_editedFrames:(NSArray *)rawFrames {
    NSMutableArray <BKRFrame *> *editedFrames = [NSMutableArray array];
    for (NSDictionary *rawFrameDict in rawFrames) {
        BKRPlayableRawFrame *rawFrame = [[BKRPlayableRawFrame alloc] initFromPlistDictionary:rawFrameDict];
        [editedFrames addObject:rawFrame.editedFrame];
    }
    return editedFrames.copy;
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

@end
