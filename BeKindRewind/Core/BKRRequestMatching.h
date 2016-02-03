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
- (BKRPlayableScene *)matchForRequest:(NSURLRequest *)request withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;;

// optional values can override this (or should I make it work the opposite of that?)
// @note: implement below optionals for more control, return YES for them to be called
// if YES is returned, then other overrides are called, if NO, then no overrides are returned
// you can implement your own checker instead of using overrides
- (BOOL)hasMatchForRequest:(NSURLRequest *)request withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;

@optional

// all of these override the one above
- (BOOL)hasMatchForRequestScheme:(NSString *)scheme withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;
- (BOOL)hasMatchForRequestUser:(NSString *)user withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;
- (BOOL)hasMatchForRequestPassword:(NSString *)password withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;
- (BOOL)hasMatchForRequestPort:(NSNumber *)port withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;
- (BOOL)hasMatchForRequestFragment:(NSString *)fragment withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;
- (BOOL)hasMatchForRequestHost:(NSString *)host withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;
- (BOOL)hasMatchForRequestPath:(NSString *)path withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;
- (BOOL)hasMatchForRequestQueryItems:(NSArray<NSURLQueryItem *> *)queryItems withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;


@end
