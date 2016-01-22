//
//  BKRCassette.m
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import "BKRCassette.h"
#import "BKRScene.h"
#import "BKRFrame.h"
#import "BKRConstants.h"

@interface BKRCassette ()
@end

@implementation BKRCassette

- (instancetype)init {
    self = [super init];
    if (self) {
        _creationDate = [NSDate date];
        _scenes = [NSMutableDictionary dictionary];
        _processingQueue = dispatch_queue_create("com.BKR.cassetteAddingQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (NSArray<BKRScene *> *)allScenes {
// TODO: check if this orders properly, possibly with a test
    __block NSArray<BKRScene *> *allScenesArray = nil;
    dispatch_barrier_sync(self.processingQueue, ^{
        allScenesArray = [self.scenes.allValues sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:BKRKey(BKRScene *, clapboardFrame.creationDate) ascending:YES]]];
    });
    return allScenesArray;
}

@end
