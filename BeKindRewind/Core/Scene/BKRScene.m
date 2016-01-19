//
//  BKRScene.m
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

//#import "NSURLSessionTask+BKRAdditions.h"
#import "BKRScene.h"
#import "BKRFrame.h"
#import "BKRData.h"
#import "BKRRequest.h"
#import "BKRResponse.h"

@interface BKRScene ()
//@property (nonatomic) NSDate *creationDate;
@property (nonatomic, copy, readwrite) NSString *uniqueIdentifier;
@property (nonatomic, strong) NSMutableArray<BKRFrame *> *frames;
@property (nonatomic, strong) NSDate *creationDate;
@end


@implementation BKRScene

//- (instancetype)initWithTask:(NSURLSessionTask *)task {
//    self = [super initWithTask:task];
//    if (self) {
//        [self _init];
//    }
//    return self;
//}

- (void)_init {
    _creationDate = [NSDate date];
    _frames = [NSMutableArray array];
}

- (instancetype)initFromFrame:(BKRFrame *)frame {
    self = [super init];
    if (self) {
        [self _init];
        _uniqueIdentifier = frame.uniqueIdentifier;
    }
    return self;
}

+ (instancetype)sceneFromFrame:(BKRFrame *)frame {
    return [[self alloc] initFromFrame:frame];
}

- (void)addFrame:(BKRFrame *)frame {
    if ([self.frames containsObject:frame]) {
        NSLog(@"Why is the same frame being added twice????????????");
    }
    [self.frames addObject:frame];
}

@end
