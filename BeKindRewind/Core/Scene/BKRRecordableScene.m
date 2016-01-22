//
//  BKRRecordableScene.m
//  Pods
//
//  Created by Jordan Zucker on 1/21/16.
//
//

#import "BKRRecordableScene.h"
#import "BKRRawFrame.h"
#import "BKRDataFrame.h"
#import "BKRResponseFrame.h"
#import "BKRRequestFrame.h"
#import "BKRError.h"

@interface BKRRecordableScene ()
@property (nonatomic, strong) NSMutableArray<BKRFrame *> *frames;
@end

@implementation BKRRecordableScene

@synthesize frames = _frames;

- (instancetype)initFromFrame:(BKRRawFrame *)frame {
    self = [super init];
    if (self) {
        self.uniqueIdentifier = frame.uniqueIdentifier;
        _frames = [NSMutableArray array];
        [self addFrame:frame];
    }
    return self;
}

+ (instancetype)sceneFromFrame:(BKRRawFrame *)frame {
    return [[self alloc] initFromFrame:frame];
}

- (void)addFrame:(BKRRawFrame *)frame {
    
    if ([self.frames containsObject:frame]) {
        NSLog(@"******************************************");
        NSLog(@"Why is the same frame being added twice????????????");
        NSLog(@"******************************************");
    }
    BKRFrame *addingFrame = nil;
    if ([frame.item isKindOfClass:[NSData class]]) {
        BKRDataFrame *dataFrame = [BKRDataFrame frameFromFrame:frame];
        [dataFrame addData:frame.item];
        addingFrame = dataFrame;
    } else if ([frame.item isKindOfClass:[NSURLResponse class]]) {
        BKRResponseFrame *responseFrame = [BKRResponseFrame frameFromFrame:frame];
        [responseFrame addResponse:frame.item];
        addingFrame = responseFrame;
    } else if ([frame.item isKindOfClass:[NSURLRequest class]]) {
        BKRRequestFrame *requestFrame = [BKRRequestFrame frameFromFrame:frame];
        [requestFrame addRequest:frame.item];
        addingFrame = requestFrame;
    } else {
        addingFrame = frame;
    }
    [self.frames addObject:addingFrame];
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
