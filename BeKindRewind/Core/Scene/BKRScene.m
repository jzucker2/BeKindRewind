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
#import "BKRDataFrame.h"
#import "BKRRequestFrame.h"
#import "BKRResponseFrame.h"
#import "BKRRawFrame.h"
#import "BKRConstants.h"

@interface BKRScene ()
//@property (nonatomic) NSDate *creationDate;
//@property (nonatomic, copy, readwrite) NSString *uniqueIdentifier;
//@property (nonatomic, strong) NSMutableArray<BKRFrame *> *frames;
@end


@implementation BKRScene

//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        _frames = [NSMutableArray array];
//    }
//    return self;
//}

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

#pragma mark - BKRDeserializer



#pragma mark - BKRSerializer

- (NSDictionary *)plistDictionary {
    return nil;
}

- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary {
    return nil;
}

//- (NSDictionary *)plistDictionary {
//    NSMutableDictionary *plistDict = [NSMutableDictionary dictionary];
//    plistDict[@"uniqueIdentifier"] = self.uniqueIdentifier;
//    NSMutableArray *plistFrames = [NSMutableArray array];
//    for (BKRFrame *frame in self.allFrames) {
//        [plistFrames addObject:frame.plistDictionary];
//    }
//    plistDict[@"frames"] = [[NSArray alloc] initWithArray:plistFrames copyItems:YES];
//    return [[NSDictionary alloc] initWithDictionary:plistDict copyItems:YES];
//}

//- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary {
//    self = [super init];
//    if (self) {
//        self.uniqueIdentifier = dictionary[@"uniqueIdentifier"];
//        for (NSDictionary *frameDict in dictionary[@"frames"]) {
//            BKRRawFrame *rawFrame = [[BKRRawFrame alloc] initFromPlistDictionary:frameDict];
//            [self addFrame:rawFrame];
//        }
//    }
//    return self;
//}

@end
