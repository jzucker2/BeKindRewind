//
//  BKROHHTTPStubsWrapper.h
//  Pods
//
//  Created by Jordan Zucker on 1/24/16.
//
//

#import <Foundation/Foundation.h>

@class BKRScene;
@class BKRResponseStub;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Test block wrapper around OHHTTPStubs test block
 *
 *  @param request network request to stub
 *
 *  @return whether or not to stub the network request
 *
 *  @since 1.0.0
 */
typedef BOOL (^BKRStubsTestBlock)(NSURLRequest* _Nonnull request);

/**
 *  Block wrapper for returning a BKRPlayableScene to use as a stub
 *  for network request mocking
 *
 *  @param request network request to stub
 *
 *  @return BKRPlayableScene to use as a stub
 *
 *  @since 1.0.0
 */
typedef BKRResponseStub* __nonnull (^BKRStubsResponseBlock)(NSURLRequest* _Nonnull request);

/**
 *  This contains information associated with the beginning of a network action.
 *
 *  @param request      this is the request being mocked
 *  @param responseStub stub associated with the request
 *
 *  @since 1.0.0
 */
typedef void (^BKRStubActivationBlock)(NSURLRequest *request, BKRResponseStub *responseStub);

/**
 *  This contains information associated with the redirecting of a network action.
 *
 *  @param request         this is the original request being mocked
 *  @param redirectRequest this is the request that will begin the redirect
 *  @param responseStub    stub associated with the request
 *
 *  @since 1.0.0
 */
typedef void (^BKRStubRedirectBlock)(NSURLRequest *request, NSURLRequest *redirectRequest, BKRResponseStub *responseStub);

/**
 *  This contains information associated with the end of a network action.
 *
 *  @param request      this is the request being mocked.
 *  @param responseStub stub associated with the request.
 *  @param error        this is the error (if any) generated during the network action.
 *
 *  @since 1.0.0
 */
typedef void (^BKRStubCompletionBlock)(NSURLRequest *request, BKRResponseStub *responseStub, NSError *error);

/**
 *  Wrapper object for abstracting the OHHTTPStubs framework
 *
 *  @since 1.0.0
 */
@interface BKROHHTTPStubsWrapper : NSObject

/**
 *  Remove all network stubs
 *
 *  @since 1.0.0
 */
+ (void)removeAllStubs;

/**
 *  If stubs are set, they can be turned on or off
 *
 *  @param enabled whether to turn stubs on or off
 *
 *  @since 1.0.0
 */
+ (void)setEnabled:(BOOL)enabled;

/**
 *  Check if stubs are currently enabled
 *
 *  @return whether stubs are enabled or not
 *
 *  @since 1.0.0
 */
+ (BOOL)hasStubs;

/**
 *  Add stub for network request using the OHHTTPStubs framework
 *
 *  @param testBlock     determines whether or not to mock a particular network request
 *  @param responseBlock if a network request is to be mocked, then this determines the data used in the stub
 *
 *  @since 1.0.0
 */
+ (void)stubRequestPassingTest:(nonnull BKRStubsTestBlock)testBlock withStubResponse:(nonnull BKRStubsResponseBlock)responseBlock;

/**
 *  This method sets a single block to be called whenever a stub begins to be used.
 *
 *  @param stubActivationBlock this returns enough information to associate a stub with a scene.
 *
 *  @since 1.0.0
 */
+ (void)onStubActivation:(nullable BKRStubActivationBlock)stubActivationBlock;

/**
 *  This method sets a single block to be called whenever a stub is returned as a redirect.
 *
 *  @param stubActivationBlock this returns enough information to associate a stub with a scene.
 *
 *  @since 1.0.0
 */
+ (void)onStubRedirectResponse:(nullable BKRStubRedirectBlock)stubRedirectBlock;

/**
 *  This method sets a single block to be called whenever a stub finishes mocking a network action.
 *
 *  @param stubActivationBlock this returns enough information to associate a stub with a scene.
 *
 *  @since 1.0.0
 */
+ (void)onStubCompletion:(nullable BKRStubCompletionBlock)stubCompletionBlock;

@end

NS_ASSUME_NONNULL_END
