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
    NSLog(@"%@: adding frame: %@", self, frame.debugDescription);
    if (!frame.item) {
        // Can't add a blank frame!
        NSLog(@"%@: can't add blank frame: %@", self, frame.debugDescription);
        return;
    }
    NSParameterAssert(frame);
    BKRWeakify(self);
    [self editScenesDictionary:^(NSDictionary<NSString *,BKRScene *> *currentScenesDictionary) {
        NSLog(@"%@: barrier async block frame (%@)", self, frame.debugDescription);
        BKRStrongify(self);
        if (!currentScenesDictionary) {
            return;
        }
        if (currentScenesDictionary[frame.uniqueIdentifier]) {
            BKRScene *existingScene = currentScenesDictionary[frame.uniqueIdentifier];
            [existingScene addFrame:frame];
        } else {
            BKRScene *newScene = [BKRScene sceneFromFrame:frame];
            [self addSceneToScenesDictionary:newScene];
        }
    }];
}

- (void)executeEndTaskRecordingBlock:(BKREndRecordingTaskBlock)endTaskBlock withTask:(NSURLSessionTask *)task {
    // just make sure there's no block before we schedule it to run
    if (!endTaskBlock) {
        return;
    }
    // needs to happen on accessingQueue so it happens after everything already being recorded
    [self editScenesDictionary:^(NSDictionary<NSString *,BKRScene *> *currentScenesDictionary) {
        // needs to happen on main queue (as per documentation) so it can be used in testing
        dispatch_async(dispatch_get_main_queue(), ^{
            endTaskBlock(task);
        });
    }];
}

- (NSDictionary *)plistDictionary {
    __block NSDictionary *finalPlistDictionary = nil;
    [self processScenes:^(NSDate *cassetteCreationDate, NSArray<BKRScene *> *currentAllScenes) {
        NSMutableArray *plistArray = [NSMutableArray array];
        for (BKRScene *scene in currentAllScenes) {
            [plistArray addObject:scene.plistDictionary];
        }
        NSMutableDictionary *plistDict = [@{
                                            @"scenes": [[NSArray alloc] initWithArray:plistArray copyItems:YES]
                                            } mutableCopy];
        plistDict[@"creationDate"] = cassetteCreationDate.copy;
        finalPlistDictionary = [[NSDictionary alloc] initWithDictionary:plistDict.copy copyItems:YES];
    }];
    return finalPlistDictionary;
}

@end
