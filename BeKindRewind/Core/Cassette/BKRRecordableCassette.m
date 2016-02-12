//
//  BKRRecordableCassette.m
//  Pods
//
//  Created by Jordan Zucker on 1/20/16.
//
//

#import "BKRRecordableCassette.h"
#import "BKRRawFrame+Recordable.h"
#import "BKRScene+Recordable.h"

@interface BKRRecordableCassette ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, BKRScene*> *scenes;
@end

@implementation BKRRecordableCassette

@synthesize scenes = _scenes;

+ (instancetype)cassette {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
//        _recording = NO;
        _scenes = [NSMutableDictionary dictionary];
    }
    return self;
}

// frames and scenes share unique identifiers, this comes from the recorded task
// if the frame matches a scene unique identifier, then add it to the scene
- (void)addFrame:(BKRRawFrame *)frame {
    if (!frame.item) {
        // Can't add a blank frame!
        return;
    }
    NSParameterAssert(frame);
    BKRWeakify(self);
    dispatch_barrier_async(self.processingQueue, ^{
        BKRStrongify(self);
        NSDictionary *currentDictionary = self.scenesDictionary;
        if (currentDictionary[frame.uniqueIdentifier]) {
            BKRScene *existingScene = currentDictionary[frame.uniqueIdentifier];
            [existingScene addFrame:frame];
        } else {
            BKRScene *newScene = [BKRScene sceneFromFrame:frame];
            [self addSceneToScenesDictionary:newScene];
        }
    });
}

- (void)executeEndTaskRecordingBlock:(BKREndRecordingTaskBlock)endTaskBlock withTask:(NSURLSessionTask *)task {
    dispatch_barrier_async(self.processingQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            endTaskBlock(task);
        });
    });
}

- (NSDictionary *)plistDictionary {
    NSMutableArray *plistArray = [NSMutableArray array];
    for (BKRScene *scene in self.allScenes) {
        [plistArray addObject:scene.plistDictionary];
    }
    NSMutableDictionary *plistDict = [@{
                                        @"scenes": [[NSArray alloc] initWithArray:plistArray copyItems:YES]
                                        } mutableCopy];
    plistDict[@"creationDate"] = self.creationDate.copy;
    return [[NSDictionary alloc] initWithDictionary:plistDict copyItems:YES];
}

@end
