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
@property (nonatomic, strong) NSMutableDictionary<NSString *, BKRScene *> *scenes;
@property (nonatomic) dispatch_queue_t accessingQueue;
@end

@implementation BKRCassette

+ (instancetype)cassette {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _creationDate = [NSDate date];
        _scenes = [NSMutableDictionary dictionary];
        _processingQueue = dispatch_queue_create("com.BKR.cassetteProcessingQueue", DISPATCH_QUEUE_CONCURRENT);
        _accessingQueue = dispatch_queue_create("com.BKR.cassetteAccessingQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (NSDictionary<NSString *, BKRScene *> *)scenesDictionary {
    __block NSDictionary<NSString *, BKRScene *> *currentScenes = nil;
    __weak typeof(self) wself = self;
    dispatch_sync(self.accessingQueue, ^{
        __strong typeof(wself) sself = wself;
        currentScenes = sself->_scenes.copy;
    });
    return currentScenes;
}

- (void)addSceneToScenesDictionary:(BKRScene *)scene {
    __weak typeof(self) wself = self;
    dispatch_barrier_async(self.accessingQueue, ^{
        __strong typeof(wself) sself = wself;
        sself->_scenes[scene.uniqueIdentifier] = scene;
    });
}

- (NSArray<BKRScene *> *)allScenes {
    return [self.scenesDictionary.allValues sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:BKRKey(BKRScene *, clapboardFrame.creationDate) ascending:YES]]];
}

@end
