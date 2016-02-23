//
//  BKRCassette.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <Foundation/Foundation.h>

@class BKRScene;

//typedef returnType (^TypeName)(parameterTypes);
//TypeName blockName = ^returnType(parameters) {...};
typedef void (^BKRCassetteSceneDictionaryAccessBlock)(NSDictionary<NSString *, BKRScene *> *currentScenesDictionary);
typedef void (^BKRCassetteAllScenesProcessingBlock)(NSDate *cassetteCreationDate, NSArray<BKRScene *> *currentAllScenes);
typedef void (^BKRCassetteBatchSceneAddingBlock)(NSDictionary *sceneDictionaryForIteration);

/**
 *  Contains the BKRScene objects associated with a networking session
 */
@interface BKRCassette : NSObject

+ (instancetype)cassette;

/**
 *  Date when this recording session is first created
 */
@property (nonatomic) NSDate *creationDate;

/**
 *  All BKRScene objects stored in this cassette
 *
 *  @return array of BKRScene objects sorted in order of creation
 */
- (NSArray<BKRScene *> *)allScenes;

/**
 *  All BKRScene objects are stored in a dictionary using a unique identifier
 *  for the scene as a key (derived from swizzling all instances of 
 *  NSURLSessionTask) and the scene as a value
 *
 *  @return dictionary of BKRScene objects hashed by unique identifier
 */
- (NSDictionary<NSString *, BKRScene *> *)scenesDictionary;

/**
 *  Used to add a BKRScene to the cassette's dictionary in a thread
 *  safe manner.
 *  
 *  @note this directly accesses ivar pointers and should only be used
 *        inside a dispatch_barrier_async or dispatch_barrier_sync block
 *
 *  @param scene represents the recorded or stubbed data associated with
 *  a network request
 */
- (void)addSceneToScenesDictionary:(BKRScene *)scene;

- (void)addBatchOfScenes:(NSArray<NSDictionary *> *)rawSceneDictionaries toCassetteWithBlock:(BKRCassetteBatchSceneAddingBlock)batchAddingBlock; // this is synchronous and blocking due to underlying dispatch_apply
- (void)editScenesDictionary:(BKRCassetteSceneDictionaryAccessBlock)sceneDictionaryAccessBlock;
- (void)processScenes:(BKRCassetteAllScenesProcessingBlock)allScenesProcessingBlock; // synchronous not async

@end
