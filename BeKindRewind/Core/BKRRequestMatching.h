//
//  BKRRequestMatching.h
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import <Foundation/Foundation.h>

@class BKRPlayableScene;
@protocol BKRRequestMatching <NSObject>

// required because it's used to initialize internally. Usually just provide standard init
+ (id<BKRRequestMatching>)matcher;


// at minimum need to provide a scene for a request. nil means that request goes live
// alternatively, if we executed a block and passed in a value like background fetch, then
// we could offer options, like fail, let go live, or provide a mock response
- (BKRPlayableScene *)matchForRequest:(NSURLRequest *)request withPlayhead:(BKRPlayableScene *)playhead inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;

@optional

// optional values can override this (or should I make it work the opposite of that?)
- (BOOL)hasMatchForRequest:(NSURLRequest *)request withPlayhead:(BKRPlayableScene *)playhead inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;

// all of these override the one above
- (BOOL)hasMatchForRequestScheme:(NSString *)scheme withPlayhead:(BKRPlayableScene *)playhead inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;
- (BOOL)hasMatchForRequestUser:(NSString *)user withPlayhead:(BKRPlayableScene *)playhead inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;
- (BOOL)hasMatchForRequestPassword:(NSString *)password withPlayhead:(BKRPlayableScene *)playhead inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;
- (BOOL)hasMatchForRequestPort:(NSNumber *)port withPlayhead:(BKRPlayableScene *)playhead inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;
- (BOOL)hasMatchForRequestFragment:(NSString *)fragment withPlayhead:(BKRPlayableScene *)playhead inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;
- (BOOL)hasMatchForRequestHost:(NSString *)host withPlayhead:(BKRPlayableScene *)playhead inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;
- (BOOL)hasMatchForRequestPath:(NSString *)path withPlayhead:(BKRPlayableScene *)playhead inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;
- (BOOL)hasMatchForRequestQueryItems:(NSArray<NSURLQueryItem *> *)queryItems withPlayhead:(BKRPlayableScene *)playhead inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;


@end
