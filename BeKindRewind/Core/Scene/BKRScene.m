//
//  BKRScene.m
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import "BKRScene.h"
#import "BKRFrame.h"
#import "BKRDataFrame.h"
#import "BKRRequestFrame.h"
#import "BKRResponseFrame.h"
#import "BKRRawFrame.h"
#import "BKRErrorFrame.h"
#import "BKRConstants.h"

@interface BKRScene ()
@end


@implementation BKRScene

- (BKRFrame *)clapboardFrame {
    return self.allFrames.firstObject;
}

- (NSArray<BKRFrame *> *)allFrames {
    return self.frames.copy;
}

- (NSArray<BKRRequestFrame *> *)allRequestFrames {
    return [self _framesOnlyOfType:[BKRRequestFrame class]];
}

- (NSArray<BKRResponseFrame *> *)allResponseFrames {
    return [self _framesOnlyOfType:[BKRResponseFrame class]];
}

- (NSArray<BKRDataFrame *> *)allDataFrames {
    return [self _framesOnlyOfType:[BKRDataFrame class]];
}

- (NSArray<BKRErrorFrame *> *)allErrorFrames {
    return [self _framesOnlyOfType:[BKRErrorFrame class]];
}

- (BKRRequestFrame *)originalRequest {
    return self.allRequestFrames.firstObject;
}

- (BKRRequestFrame *)currentRequest {
    if (self.allRequestFrames.count > 1) {
        return [self.allRequestFrames objectAtIndex:1];
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
