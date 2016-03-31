//
//  BKRScene+Recordable.m
//  Pods
//
//  Created by Jordan Zucker on 2/12/16.
//
//

#import "BKRScene+Recordable.h"
#import "BKRRawFrame+Recordable.h"

@implementation BKRScene (Recordable)

- (instancetype)initFromFrame:(BKRRawFrame *)frame withContext:(BKRRecordingContext)context {
    self = [self init];
    if (self) {
        self.uniqueIdentifier = frame.uniqueIdentifier;
        [self addFrame:frame withContext:context];
    }
    return self;
}

+ (instancetype)sceneFromFrame:(BKRRawFrame *)frame withContext:(BKRRecordingContext)context {
    return [[self alloc] initFromFrame:frame withContext:context];
}

- (void)addFrame:(BKRRawFrame *)frame withContext:(BKRRecordingContext)context {
    [self addFrameToFramesArray:[frame editedRecordingWithContext:context]];
}

- (NSDictionary *)plistDictionary {
    NSMutableDictionary *plistDict = [NSMutableDictionary dictionary];
    plistDict[@"uniqueIdentifier"] = self.uniqueIdentifier;
    NSMutableArray *plistFrames = [NSMutableArray array];
    for (BKRFrame *frame in self.allFrames) {
        [plistFrames addObject:frame.plistDictionary];
    }
    plistDict[@"frames"] = [[NSArray alloc] initWithArray:plistFrames copyItems:YES];
    return [[NSDictionary alloc] initWithDictionary:plistDict copyItems:YES];
}

@end
