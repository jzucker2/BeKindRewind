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
@synthesize recording = _recording;

- (instancetype)init {
    self = [super init];
    if (self) {
        _recording = NO;
        _scenes = [NSMutableDictionary dictionary];
    }
    return self;
}

// frames and scenes share unique identifiers, this comes from the recorded task
// if the frame matches a scene unique identifier, then add it to the scene
- (void)addFrame:(BKRRecordableRawFrame *)frame {
    if (!self.isRecording) {
        // Can't add frames if you are not recording!
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

- (BOOL)isRecording {
    __block BOOL currentIsRecording;
    __weak typeof(self) wself = self;
    dispatch_sync(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        currentIsRecording = sself->_recording;
    });
    return currentIsRecording;
}

- (void)setRecording:(BOOL)recording {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        sself->_recording = recording;
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
