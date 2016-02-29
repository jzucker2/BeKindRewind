//
//  BKRCassette.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <Foundation/Foundation.h>

@class BKRScene;

/**
 *  Block used to access an immutable dictionary of all scenes in the BKRCassette instance
 *
 *  @param NSDictionary<NSString *, BKRScene *> *currentScenesDictionary  has values 
 *  for all current BKRScene instances contained in the cassette with the scene's unique identifier used as the key.
 */
typedef void (^BKRCassetteSceneDictionaryAccessBlock)(NSDictionary<NSString *, BKRScene *> *currentScenesDictionary);

/**
 *  This block contains all the information assocated with a BKRCassette instance
 *
 *  @param version              current version of the BKRCassette instance
 *  @param cassetteCreationDate the creationDate of the BKRCassette instance
 *  @param currentAllScenes     all the BKRScene objects from the BKRCassette instance
 */
typedef void (^BKRCassetteAllScenesProcessingBlock)(NSString *version, NSDate *cassetteCreationDate, NSArray<BKRScene *> *currentAllScenes);

/**
 *  This block is used to add a batch of Foundation objects to a BKRCassette instance. This block
 *  is assumed to be thread-safe
 *
 *  @param sceneDictionaryForIteration this is a dictionary of Foundation objects that needs
 *                                     to be converted and added to a BKRCassette instance
 */
typedef void (^BKRCassetteBatchSceneAddingBlock)(NSDictionary *sceneDictionaryForIteration);

/**
 *  Contains the BKRScene objects associated with a networking session
 */
@interface BKRCassette : NSObject

/**
 *  Version of cassette. This is associated with the framework version.
 */
@property (nonatomic, copy) NSString *version;

/**
 *  Convenience constructor.
 *
 *  @return a blank instance of the class.
 */
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

/**
 *  Thread-safe method for adding information to a cassette in the format
 *  of raw NSDictionary objects. This method is overall synchronous, though each
 *  batchAddingBlock execution is asynchronous. This method is blocking in the
 *  queue it executes in.
 *
 *  @param rawSceneDictionaries dictionary contains only Foundation objects
 *  @param batchAddingBlock     block containing information only composed of Foundation objects
 *                              to init a single instance of a BKRScene object
 */
- (void)addBatchOfScenes:(NSArray<NSDictionary *> *)rawSceneDictionaries toCassetteWithBlock:(BKRCassetteBatchSceneAddingBlock)batchAddingBlock;

/**
 *  Used to add frames to an instance of a BKRScene in the receiver
 *
 *  @param sceneDictionaryAccessBlock thread-safe block to edit a scene in the receiver
 */
- (void)editScenesDictionary:(BKRCassetteSceneDictionaryAccessBlock)sceneDictionaryAccessBlock;

/**
 *  This is a thread-safe method, synchronous method that calls a block on the receiver containing
 *  all the information contained within the receiver. This thread is blocking on the queue it is
 *  called in.
 *
 *  @param allScenesProcessingBlock this is called in the receiver's custom queue and contains all
 *                                  the information associated with the receiver at the moment the
 *                                  method is called
 */
- (void)processScenes:(BKRCassetteAllScenesProcessingBlock)allScenesProcessingBlock; // synchronous not async

@end
