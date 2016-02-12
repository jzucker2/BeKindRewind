//
//  BKRRecordableCassette.m
//  Pods
//
//  Created by Jordan Zucker on 1/20/16.
//
//

#import "BKRRecordableCassette.h"
#import "BKRRecordableRawFrame.h"
#import "BKRRecordableScene.h"

@interface BKRRecordableCassette ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, BKRRecordableScene*> *scenes;
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
- (void)addFrame:(BKRRecordableRawFrame *)frame {
    if (!frame.item) {
        // Can't add a blank frame!
        return;
    }
    NSParameterAssert(frame);
    __weak typeof (self) wself = self;
    dispatch_barrier_async(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        NSDictionary *currentDictionary = sself.scenesDictionary;
        if (currentDictionary[frame.uniqueIdentifier]) {
            BKRRecordableScene *existingScene = currentDictionary[frame.uniqueIdentifier];
            [existingScene addFrame:frame];
        } else {
            BKRRecordableScene *newScene = [BKRRecordableScene sceneFromFrame:frame];
            [sself addSceneToScenesDictionary:newScene];
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
    for (BKRRecordableScene *scene in self.allScenes) {
        [plistArray addObject:scene.plistDictionary];
    }
    NSMutableDictionary *plistDict = [@{
                                        @"scenes": [[NSArray alloc] initWithArray:plistArray copyItems:YES]
                                        } mutableCopy];
    plistDict[@"creationDate"] = self.creationDate.copy;
    return [[NSDictionary alloc] initWithDictionary:plistDict copyItems:YES];
}

@end
