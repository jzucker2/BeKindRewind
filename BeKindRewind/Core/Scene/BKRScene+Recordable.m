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

- (instancetype)initFromFrame:(BKRRawFrame *)frame {
    self = [self init];
    if (self) {
        self.uniqueIdentifier = frame.uniqueIdentifier;
        [self addFrame:frame];
    }
    return self;
}

+ (instancetype)sceneFromFrame:(BKRRawFrame *)frame {
    return [[self alloc] initFromFrame:frame];
}

- (void)addFrame:(BKRRawFrame *)frame {
    [self addFrameToFramesArray:frame.editedRecording];
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
