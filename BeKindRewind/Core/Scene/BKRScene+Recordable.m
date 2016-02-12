//
//  BKRScene+Recordable.m
//  Pods
//
//  Created by Jordan Zucker on 2/12/16.
//
//

#import "BKRScene+Recordable.h"
#import "BKRRecordableRawFrame.h"

@implementation BKRScene (Recordable)

- (instancetype)initFromFrame:(BKRRecordableRawFrame *)frame {
    self = [self init];
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
