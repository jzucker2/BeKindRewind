//
//  BKROHHTTPStubsWrapper.h
//  Pods
//
//  Created by Jordan Zucker on 1/24/16.
//
//

#import <Foundation/Foundation.h>

@class BKRScene;
@class BKRSceneResponseStub;
@class BKRResponseStub;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Test block wrapper around OHHTTPStubs test block
 *
 *  @param request network request to stub
 *
 *  @return whether or not to stub the network request
 */
typedef BOOL (^BKRStubsTestBlock)(NSURLRequest* _Nonnull request);

/**
 *  Block wrapper for returning a BKRPlayableScene to use as a stub
 *  for network request mocking
 *
 *  @param request network request to stub
 *
 *  @return BKRPlayableScene to use as a stub
 */
typedef BKRSceneResponseStub* __nonnull (^BKRStubsResponseBlock)(NSURLRequest* _Nonnull request);

typedef void (^BKRStubActivationBlock)(NSURLRequest *request, BKRResponseStub *responseStub);
typedef void (^BKRStubRedirectBlock)(NSURLRequest *request, NSURLRequest *redirectRequest, BKRResponseStub *responseStub);
typedef void (^BKRStubCompletionBlock)(NSURLRequest *request, BKRResponseStub *responseStub, NSError *error);

/**
 *  Wrapper object for abstracting the OHHTTPStubs framework
 */
@interface BKROHHTTPStubsWrapper : NSObject

/**
 *  Remove all network stubs
 */
+ (void)removeAllStubs;

/**
 *  If stubs are set, they can be turned on or off
 *
 *  @param enabled whether to turn stubs on or off
 */
+ (void)setEnabled:(BOOL)enabled;

/**
 *  Check if stubs are currently enabled
 *
 *  @return whether stubs are enabled or not
 */
+ (BOOL)hasStubs;

/**
 *  Add stub for network request using the OHHTTPStubs framework
 *
 *  @param testBlock     determines whether or not to mock a particular network request
 *  @param responseBlock if a network request is to be mocked, then this determines the data used in the stub
 */
+ (void)stubRequestPassingTest:(nonnull BKRStubsTestBlock)testBlock withStubResponse:(nonnull BKRStubsResponseBlock)responseBlock;

+ (void)onStubActivation:(nullable BKRStubActivationBlock)stubActivationBlock;
+ (void)onStubRedirectResponse:(nullable BKRStubRedirectBlock)stubRedirectBlock;
+ (void)onStubCompletion:(nullable BKRStubCompletionBlock)stubCompletionBlock;

@end

NS_ASSUME_NONNULL_END
