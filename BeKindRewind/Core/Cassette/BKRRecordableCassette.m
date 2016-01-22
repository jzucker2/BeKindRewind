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

- (instancetype)init {
    self = [super init];
    if (self) {
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
        if (sself.scenes[frame.uniqueIdentifier]) {
            BKRRecordableScene *existingScene = sself.scenes[frame.uniqueIdentifier];
            [existingScene addFrame:frame];
        } else {
            BKRRecordableScene *newScene = [BKRRecordableScene sceneFromFrame:frame];
            sself.scenes[newScene.uniqueIdentifier] = newScene;
        }
    });
}

- (void)setRecording:(BOOL)recording {
    dispatch_barrier_sync(self.processingQueue, ^{
        _recording = recording;
    });
    if (_recording) {
        self.creationDate = [NSDate date];
    } else {
        
    }
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
