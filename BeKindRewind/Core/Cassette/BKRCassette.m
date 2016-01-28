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
//@property (nonatomic, strong) NSDictionary *scenes;
@end

@implementation BKRCassette

- (instancetype)init {
    self = [super init];
    if (self) {
        _creationDate = [NSDate date];
        _scenes = [NSDictionary dictionary];
        _processingQueue = dispatch_queue_create("com.BKR.cassetteAddingQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (NSArray<BKRScene *> *)allScenes {
// TODO: check if this orders properly, possibly with a test
    NSLog(@"begin returning allScenes");
    __block NSArray<BKRScene *> *allScenesArray = nil;
    __weak typeof(self) wself = self;
    dispatch_barrier_sync(self.processingQueue, ^{
        __strong typeof(wself) sself = wself;
        allScenesArray = [sself.scenes.allValues sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:BKRKey(BKRScene *, clapboardFrame.creationDate) ascending:YES]]];
    });
    NSLog(@"return allScenes");
    return allScenesArray;
}

@end
