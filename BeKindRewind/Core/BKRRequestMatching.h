//
//  BKRRequestMatching.h
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import <Foundation/Foundation.h>

@class BKRScene;

/**
 This protocol is adopted by the object used to construct the rules for network
 request playback matching performed by the BKRPlayer. This is where you should
 define the rules used to match network requests during playback.
 
 */
@protocol BKRRequestMatching <NSObject>

/**
 *  This is used as the constructor of the matcher, it must be provided.
 *  @note Typically you can just provide a standard init
 *
 *  @return instance of a matcher class conforming to this protocol
 */
+ (id<BKRRequestMatching>)matcher;

/**
 *  This is used to create the stubbed response for a request that is expecting to be mocked.
 *  When this block executes, the test block will have already passed.
 *  @warning undefined if nil is returned.
 *
 *  @param request      request which is to receive a mocked response
 *  @param firstMatched index of first matched BKRPlayableScene
 *  @param networkCalls number of network calls stubbed so far
 *  @param scenes       array of BKRPlayableScene objects for use as potential stubs
 *
 *  @return a BKRPlayableScene to use as a stub for this request
 */
- (BKRScene *)matchForRequest:(NSURLRequest *)request withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRScene *> *)scenes;;

/**
 *  This is used by the test block to check whether a stubbed response should be provided for
 *  a request.
 *
 *  @param request      possible request to stub
 *  @param firstMatched index of first matched BKRPlayableScene
 *  @param networkCalls number of network calls stubbed so far
 *  @param scenes       array of BKRPlayableScene objects for use as potential stubs
 *
 *  @note implement optional fine grained methods to simplify matcher
 *
 *  @return whether or not to stub the request. If NO is returned, then the request is not stubbed
 *  and continues live and uninterrupted. If YES is returned, and other optional boolean methods are
 *  implemented, then they will be executed as well.
 */
- (BOOL)hasMatchForRequest:(NSURLRequest *)request withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRScene *> *)scenes;

@optional

/**
 *  Convenience callback for testing the scheme of a request for possible stubbing
 *
 *  @param scheme       scheme from request URL currently being tested
 *  @param firstMatched index of first matched BKRPlayableScene
 *  @param networkCalls number of network calls stubbed so far
 *  @param scenes       array of BKRPlayableScene objects for use as potential stubs
 *
 *  @return whether or not to stub the request
 */
- (BOOL)hasMatchForRequestScheme:(NSString *)scheme withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRScene *> *)scenes;

/**
 *  Convenience callback for testing the user of a request for possible stubbing
 *
 *  @param user         user from request URL currently being tested
 *  @param firstMatched index of first matched BKRPlayableScene
 *  @param networkCalls number of network calls stubbed so far
 *  @param scenes       array of BKRPlayableScene objects for use as potential stubs
 *
 *  @return whether or not to stub the request
 */
- (BOOL)hasMatchForRequestUser:(NSString *)user withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRScene *> *)scenes;

/**
 *  Convenience callback for testing the password of a request for possible stubbing
 *
 *  @param password     password from request URL currently being tested
 *  @param firstMatched index of first matched BKRPlayableScene
 *  @param networkCalls number of network calls stubbed so far
 *  @param scenes       array of BKRPlayableScene objects for use as potential stubs
 *
 *  @return whether or not to stub the request
 */
- (BOOL)hasMatchForRequestPassword:(NSString *)password withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRScene *> *)scenes;

/**
 *  Convenience callback for testing the port of a request for possible stubbing
 *
 *  @param port         port from request URL currently being tested
 *  @param firstMatched index of first matched BKRPlayableScene
 *  @param networkCalls number of network calls stubbed so far
 *  @param scenes       array of BKRPlayableScene objects for use as potential stubs
 *
 *  @return whether or not to stub the request
 */
- (BOOL)hasMatchForRequestPort:(NSNumber *)port withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRScene *> *)scenes;

/**
 *  Convenience callback for testing the fragment of a request for possible stubbing
 *
 *  @param fragment     fragment from request URL currently being tested
 *  @param firstMatched index of first matched BKRPlayableScene
 *  @param networkCalls number of network calls stubbed so far
 *  @param scenes       array of BKRPlayableScene objects for use as potential stubs
 *
 *  @return whether or not to stub the request
 */
- (BOOL)hasMatchForRequestFragment:(NSString *)fragment withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRScene *> *)scenes;

/**
 *  Convenience callback for testing the host of a request for possible stubbing
 *
 *  @param password     host from request URL currently being tested
 *  @param firstMatched index of first matched BKRPlayableScene
 *  @param networkCalls number of network calls stubbed so far
 *  @param scenes       array of BKRPlayableScene objects for use as potential stubs
 *
 *  @return whether or not to stub the request
 */
- (BOOL)hasMatchForRequestHost:(NSString *)host withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRScene *> *)scenes;

/**
 *  Convenience callback for testing the path of a request for possible stubbing
 *
 *  @param path         path from request URL currently being tested
 *  @param firstMatched index of first matched BKRPlayableScene
 *  @param networkCalls number of network calls stubbed so far
 *  @param scenes       array of BKRPlayableScene objects for use as potential stubs
 *
 *  @return whether or not to stub the request
 */
- (BOOL)hasMatchForRequestPath:(NSString *)path withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRScene *> *)scenes;

/**
 *  Convenience callback for testing the query items of a request for possible stubbing
 *
 *  @param queryItems   array of NSURLQueryItem objects from request URL currently being tested
 *  @param firstMatched index of first matched BKRPlayableScene
 *  @param networkCalls number of network calls stubbed so far
 *  @param scenes       array of BKRPlayableScene objects for use as potential stubs
 *
 *  @return whether or not to stub the request
 */
- (BOOL)hasMatchForRequestQueryItems:(NSArray<NSURLQueryItem *> *)queryItems withFirstMatchedIndex:(NSUInteger)firstMatched currentNetworkCalls:(NSUInteger)networkCalls inPlayableScenes:(NSArray<BKRScene *> *)scenes;

@end
