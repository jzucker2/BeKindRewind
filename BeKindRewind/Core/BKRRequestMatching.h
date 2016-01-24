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
- (BKRPlayableScene *)matchForRequest:(NSURLRequest *)request withPlayheadIdentifier:(NSString *)playheadIdentifier inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;

@optional

// optional values can override this (or should I make it work the opposite of that?)
- (BOOL)hasMatchForRequest:(NSURLRequest *)request withPlayheadIdentifier:(NSString *)playheadIdentifier inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;

// all of these override the one above
- (BOOL)hasMatchForRequestScheme:(NSString *)scheme withPlayheadIdentifier:(NSString *)playheadIdentifier inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;
- (BOOL)hasMatchForRequestUser:(NSString *)user withPlayheadIdentifier:(NSString *)playheadIdentifier inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;
- (BOOL)hasMatchForRequestPassword:(NSString *)password withPlayheadIdentifier:(NSString *)playheadIdentifier inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;
- (BOOL)hasMatchForRequestPort:(NSNumber *)port withPlayheadIdentifier:(NSString *)playheadIdentifier inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;
- (BOOL)hasMatchForRequestFragment:(NSString *)fragment withPlayheadIdentifier:(NSString *)playheadIdentifier inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;
- (BOOL)hasMatchForRequestHost:(NSString *)host withPlayheadIdentifier:(NSString *)playheadIdentifier inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;
- (BOOL)hasMatchForRequestPath:(NSString *)path withPlayheadIdentifier:(NSString *)playheadIdentifier inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;
- (BOOL)hasMatchForRequestQueryItems:(NSArray<NSURLQueryItem *> *)queryItems withPlayheadIdentifier:(NSString *)playheadIdentifier inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;


@end
