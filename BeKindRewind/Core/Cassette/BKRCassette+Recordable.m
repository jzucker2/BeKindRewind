//
//  BKRCassette+Recordable.m
//  Pods
//
//  Created by Jordan Zucker on 2/15/16.
//
//

#import "BKRCassette+Recordable.h"
#import "BKRRawFrame+Recordable.h"
#import "BKRScene+Recordable.h"

@implementation BKRCassette (Recordable)

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
    // needs to happen on processingQueue so it happens after everything already being recorded
    dispatch_barrier_async(self.processingQueue, ^{
        // needs to happen on main queue (as per documentation) so it can be used in testing
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
