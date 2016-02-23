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
    BKRWeakify(self);
    dispatch_sync(self.accessingQueue, ^{
        BKRStrongify(self);
        currentScenes = self->_scenes.copy;
    });
    return currentScenes;
}

- (void)addSceneToScenesDictionary:(BKRScene *)scene {
//    BKRWeakify(self);
//    dispatch_barrier_async(self.accessingQueue, ^{
//        BKRStrongify(self);
//        self->_scenes[scene.uniqueIdentifier] = scene;
//    });
    self->_scenes[scene.uniqueIdentifier] = scene;
}

- (void)addBatchOfScenes:(NSArray<NSDictionary *> *)rawSceneDictionaries toCassetteWithBlock:(BKRCassetteBatchSceneAddingBlock)batchAddingBlock {
    // if there's nothing to process (no block or array has is nil or has nothing) then skip
    if (
        !batchAddingBlock ||
        !rawSceneDictionaries ||
        !rawSceneDictionaries.count
        ) {
        return;
    }
    dispatch_apply(rawSceneDictionaries.count, self.accessingQueue, ^(size_t iteration) {
        batchAddingBlock(rawSceneDictionaries[iteration]);
    });
}

- (NSArray<BKRScene *> *)allScenes {
//    __block NSArray<BKRScene *> *currentAllScenes = nil;
//    BKRWeakify(self);
//    dispatch_sync(self.accessingQueue, ^{
//        BKRStrongify(self);
//        currentAllScenes = [self->_scenes.allValues sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:BKRKey(BKRScene *, clapboardFrame.creationDate) ascending:YES]]];
//    });
//    return currentAllScenes;
    
//    return [self.scenesDictionary.allValues sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:BKRKey(BKRScene *, clapboardFrame.creationDate) ascending:YES]]];
    return [self _scenesSortedByClapboardFrameCreationDate:self.scenesDictionary];
}

- (NSArray<BKRScene *> *)_scenesSortedByClapboardFrameCreationDate:(NSDictionary<NSString *, BKRScene *> *)aScenesDictionary {
    return [aScenesDictionary.allValues sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:BKRKey(BKRScene *, clapboardFrame.creationDate) ascending:YES]]];
}

- (void)editScenesDictionary:(BKRCassetteSceneDictionaryAccessBlock)sceneDictionaryAccessBlock {
    if (!sceneDictionaryAccessBlock) {
        return;
    }
    BKRWeakify(self);
    dispatch_barrier_async(self.accessingQueue, ^{
        BKRStrongify(self);
        sceneDictionaryAccessBlock(self->_scenes);
    });
}

- (void)processScenes:(BKRCassetteAllScenesProcessingBlock)allScenesProcessingBlock {
    if (!allScenesProcessingBlock) {
        return;
    }
    BKRWeakify(self);
    dispatch_barrier_sync(self.accessingQueue, ^{
        BKRStrongify(self);
        allScenesProcessingBlock(self.creationDate, [self _scenesSortedByClapboardFrameCreationDate:self->_scenes]);
    });
}

@end
