//
//  BKRCassette.m
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import "BKRCassette.h"
#import "BKRRawFrame.h"
#import "BKRScene.h"
#import "BKRConstants.h"

@interface BKRCassette ()
@property (nonatomic, strong) NSMutableDictionary *scenes;
@property (nonatomic) dispatch_queue_t addingQueue;
@property (nonatomic) NSDate *creationDate;
@end

@implementation BKRCassette

- (instancetype)init {
    self = [super init];
    if (self) {
        _creationDate = [NSDate date];
        _scenes = [NSMutableDictionary dictionary];
        _addingQueue = dispatch_queue_create("com.BKR.cassetteAddingQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

// frames and scenes share unique identifiers, this comes from the recorded task
// if the frame matches a scene unique identifier, then add it to the scene
- (void)addFrame:(BKRRawFrame *)frame {
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
        _creationDate = [NSDate date];
    } else {
        
    }
}

- (NSArray<BKRScene *> *)allScenes {
// TODO: check if this orders properly, possibly with a test
    return [self.scenes.allValues sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:BKRKey(BKRScene *, clapboardFrame.creationDate) ascending:YES]]];
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

- (id)bkrRepresentation {
    return nil;
}

@end
