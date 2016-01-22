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
@property (nonatomic, strong) NSMutableArray<BKRFrame *> *frames;
@end

@implementation BKRRecordableScene

@synthesize frames = _frames;

- (instancetype)initFromFrame:(BKRRecordableRawFrame *)frame {
    self = [super init];
    if (self) {
        self.uniqueIdentifier = frame.uniqueIdentifier;
        _frames = [NSMutableArray array];
        [self addFrame:frame];
    }
    return self;
}

+ (instancetype)sceneFromFrame:(BKRRecordableRawFrame *)frame {
    return [[self alloc] initFromFrame:frame];
}

- (void)addFrame:(BKRRecordableRawFrame *)frame {
    
    if ([self.frames containsObject:frame]) {
        NSLog(@"******************************************");
        NSLog(@"Why is the same frame being added twice????????????");
        NSLog(@"******************************************");
    }
    [self.frames addObject:frame.editedFrame];
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
