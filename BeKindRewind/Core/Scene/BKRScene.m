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
@property (nonatomic, copy, readwrite) NSString *uniqueIdentifier;
@property (nonatomic, strong) NSMutableArray<BKRFrame *> *frames;
@end


@implementation BKRScene

- (void)_init {
    _frames = [NSMutableArray array];
}

- (instancetype)initFromFrame:(BKRRawFrame *)frame {
    self = [super init];
    if (self) {
        [self _init];
        _uniqueIdentifier = frame.uniqueIdentifier;
        [self addFrame:frame];
    }
    return self;
}

+ (instancetype)sceneFromFrame:(BKRRawFrame *)frame {
    return [[self alloc] initFromFrame:frame];
}

- (BKRFrame *)clapboardFrame {
    return self.allFrames.firstObject;
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
    NSMutableDictionary *plistDict = [NSMutableDictionary dictionary];
    plistDict[@"uniqueIdentifier"] = self.uniqueIdentifier;
    NSMutableArray *plistFrames = [NSMutableArray array];
    for (BKRFrame *frame in self.allFrames) {
        [plistFrames addObject:frame.plistDictionary];
    }
    plistDict[@"frames"] = [[NSArray alloc] initWithArray:plistFrames copyItems:YES];
    return [[NSDictionary alloc] initWithDictionary:plistDict copyItems:YES];
}

- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        [self _init];
        _uniqueIdentifier = dictionary[@"uniqueIdentifier"];
        
    }
    return self;
}

@end
