//
//  BKRRecordableScene.m
//  Pods
//
//  Created by Jordan Zucker on 1/21/16.
//
//

#import "BKRRecordableScene.h"
#import "BKRRecordableRawFrame.h"

@interface BKRRecordableScene ()
@end

@implementation BKRRecordableScene

- (instancetype)initFromFrame:(BKRRecordableRawFrame *)frame {
    self = [super init];
    if (self) {
        self.uniqueIdentifier = frame.uniqueIdentifier;
        [self addFrame:frame];
    }
    return self;
}

+ (instancetype)sceneFromFrame:(BKRRecordableRawFrame *)frame {
    return [[self alloc] initFromFrame:frame];
}

- (void)addFrame:(BKRRecordableRawFrame *)frame {
    [self addFrameToFramesArray:frame.editedFrame];
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
