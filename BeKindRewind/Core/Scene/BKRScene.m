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
        [self addFrame:frame];
    }
    return self;
}

+ (instancetype)sceneFromFrame:(BKRFrame *)frame {
    return [[self alloc] initFromFrame:frame];
}

- (void)addFrame:(BKRFrame *)frame {
    if ([self.frames containsObject:frame]) {
        NSLog(@"******************************************");
        NSLog(@"Why is the same frame being added twice????????????");
        NSLog(@"******************************************");
    }
    [self.frames addObject:frame];
}

- (NSArray<BKRFrame *> *)allFrames {
    return self.frames.copy;
}

- (NSArray<BKRRequest *> *)allRequestFrames {
    return [self _framesOnlyOfType:[BKRRequest class]];
}

- (NSArray<BKRResponse *> *)allResponseFrames {
    return [self _framesOnlyOfType:[BKRResponse class]];
}

- (NSArray<BKRData *> *)allDataFrames {
    return [self _framesOnlyOfType:[BKRData class]];
}

- (BKRRequest *)originalRequest {
    for (BKRFrame *frame in self.allFrames) {
        if ([frame isKindOfClass:[BKRRequest class]]) {
            BKRRequest *request = (BKRRequest *)frame;
            if (request.isOriginalRequest) {
                return request;
            }
        }
    }
    return nil;
}

- (NSArray *)_framesOnlyOfType:(Class)frameClass {
    NSMutableArray *restrictedFrames = [NSMutableArray array];
    for (BKRFrame *frame in self.allFrames) {
        if ([frame isKindOfClass:frameClass]) {
            [restrictedFrames addObject:frame];
        } else {
            continue;
        }
    }
    return restrictedFrames.copy;
}

@end
