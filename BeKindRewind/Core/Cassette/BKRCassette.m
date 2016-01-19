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
@end

@implementation BKRCassette

//- (void)addScene:(BKRScene *)scene {
//    
//}

- (instancetype)init {
    self = [super init];
    if (self) {
        _scenes = [NSMutableDictionary dictionary];
    }
    return self;
}

// frames and scenes share unique identifiers, this comes from the recorded task
// if the frame matches a scene unique identifier, then add it to the scene
- (void)addFrame:(BKRFrame *)frame {
    if (!self.isRecording) {
        // Can't add frames if you are recording!
        return;
    }
    NSParameterAssert(frame);
    if (self.scenes[frame.uniqueIdentifier]) {
        BKRScene *existingScene = self.scenes[frame.uniqueIdentifier];
        [existingScene addFrame:frame];
    } else {
        BKRScene *newScene = [BKRScene sceneFromFrame:frame];
        self.scenes[newScene.uniqueIdentifier] = newScene;
    }
}

- (void)setRecording:(BOOL)recording {
    _recording = recording;
    if (_recording) {
        
    } else {
        
    }
}

@end
