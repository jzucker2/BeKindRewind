//
//  BKRCassette.m
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import "BKRCassette.h"
#import "BKRFrame.h"
#import "BKRScene.h"

@interface BKRCassette ()
@property (nonatomic, strong) NSMutableDictionary *scenes;
@property (nonatomic) dispatch_queue_t addingQueue;
@end

@implementation BKRCassette

//- (void)addScene:(BKRScene *)scene {
//    
//}

- (instancetype)init {
    self = [super init];
    if (self) {
        _scenes = [NSMutableDictionary dictionary];
        _addingQueue = dispatch_queue_create("com.BKR.cassetteAddingQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

// frames and scenes share unique identifiers, this comes from the recorded task
// if the frame matches a scene unique identifier, then add it to the scene
- (void)addFrame:(BKRFrame *)frame {
    if (!self.isRecording) {
        // Can't add frames if you are not recording!
        return;
    }
    NSParameterAssert(frame);
    __weak typeof (self) wself = self;
    dispatch_async(self.addingQueue, ^{
        __strong typeof(wself) sself = wself;
        if (sself.scenes[frame.uniqueIdentifier]) {
            BKRScene *existingScene = sself.scenes[frame.uniqueIdentifier];
            [existingScene addFrame:frame];
        } else {
            BKRScene *newScene = [BKRScene sceneFromFrame:frame];
            sself.scenes[newScene.uniqueIdentifier] = newScene;
        }
    });
}

- (void)setRecording:(BOOL)recording {
    _recording = recording;
    if (_recording) {
        
    } else {
        
    }
}

- (NSArray *)allScenes {
    return self.scenes.allValues;
}

@end
