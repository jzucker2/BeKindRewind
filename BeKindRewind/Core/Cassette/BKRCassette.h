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
 *  Contains the BKRScene objects associated with a networking session
 */
@interface BKRCassette : NSObject

/**
 *  Date when this recording session is first created
 */
@property (nonatomic) NSDate *creationDate;

/**
 *  Concurrent queue used to process BKRScene objects
 */
@property (nonatomic) dispatch_queue_t processingQueue;

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
 *  @param scene represents the recorded or stubbed data associated with
 *  a network request
 */
- (void)addSceneToScenesDictionary:(BKRScene *)scene;

@end
