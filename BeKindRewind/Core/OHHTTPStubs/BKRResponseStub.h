//
//  BKRResponseStub.h
//  Pods
//
//  Created by Jordan Zucker on 3/10/16.
//
//

#import <Foundation/Foundation.h>

#warning docs
#pragma mark - Defines & Constants
// Non-standard download speeds
extern const double
BKRDownloadSpeed1KBPS,					// 1.0 KB per second
BKRDownloadSpeedSLOW;					// 1.5 KB per second

// Standard download speeds.
extern const double
BKRDownloadSpeedGPRS,
BKRDownloadSpeedEDGE,
BKRDownloadSpeed3G,
BKRDownloadSpeed3GPlus,
BKRDownloadSpeedWifi;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Interface

@class OHHTTPStubsResponse;

/**
 *  This is used by BeKindRewind to mock a server response. This instance 
 *  contains everything necessary to stub the response using the OHHTTPStubs 
 *  framework.
 *
 *  @since 1.0.0
 */
@interface BKRResponseStub : NSObject

/**
 *  This is a convenience initializer that is used by OHHTTPStubs to mock a 
 *  network response that does not end in an error.
 *
 *  @param data       this is the information returned for the request that is being mocked.
 *  @param statusCode this is the HTTP code returned for the request that is being mocked.
 *  @param headers    this is the HTTP headers returned for the request that is being mocked.
 *
 *  @return newly initialized instance of BKRResponseStub
 *
 *  @since 1.0.0
 */
+ (instancetype)responseWithData:(nullable NSData *)data statusCode:(int)statusCode headers:(nullable NSDictionary *)headers;

/**
 *  This is a convenience initializer used by OHHTTPStubs to mock a network response that
 *  does not end in an error and has no data. This is mostly used for redirect mocking.
 *
 *  @param statusCode this is the HTTP code returned for the request that is being mocked.
 *  @param headers    this is the HTTP headers returned for the request that is being mocked.
 *
 *  @return newly initialized instance of BKRResponseStub
 *
 *  @since 2.0.0
 */
+ (instancetype)responseWithStatusCode:(int)statusCode headers:(nullable NSDictionary *)headers;

/**
 *  This is a convenience initializer that is used by OHHTTPStubs to mock a network
 *  response that ends in an error.
 *
 *  @param error this is everything associated with the failed or error-ed network request.
 *
 *  @return newly initialized instance of BKRResponseStub
 *
 *  @since 1.0.0
 */
+ (instancetype)responseWithError:(NSError *)error;

/**
 *  This is a convenience initializer used to represent a stubs response 
 *  from OHHTTPStubs that is being called by an activation, redirection,
 *  or completion block.
 *
 *  @param response this is an object native to the OHHTTPStubs framework.
 *
 *  @return newly initialized instance of BKRResponseStub
 *
 *  @since 1.0.0
 */
+ (instancetype)responseWithStubsResponse:(OHHTTPStubsResponse *)response;

/**
 *  This is provided to OHHTTPStubs that is delivered for the mocked network action.
 *
 *  @since 1.0.0
 */
@property (nonatomic, strong, readonly, nullable) NSInputStream *inputStream;

/**
 *  This is the size of the data to mock the network action.
 *
 *  @since 1.0.0
 */
@property (nonatomic, assign, readonly) unsigned long long dataSize;

/**
 *  This is the status code used for the network response.
 *
 *  @since 1.0.0
 */
@property (nonatomic, assign, readonly) int statusCode;

/**
 *  This is a dictionary of headers associated with the network action.
 *
 *  @since 1.0.0
 */
@property (nonatomic, strong, readonly, nullable) NSDictionary *headers;

/**
 *  This property determines whether the response is an error or a 
 *  network action. If this is not nil then all other properties are 
 *  ignored and only this is used to mock the network action.
 *
 *  @since 1.0.0
 */
@property (nonatomic, strong, readonly, nullable) NSError *error;

/**
 *  The duration to wait before faking receiving the response headers.
 *  This is the actual value applied to a mocked network action during
 *  playing. It represents the time elapsed between a network request 
 *  beginning and the NSURLResponse being received. Defaults to 0.0.
 *
 *  @note must be set to a value greater than or equal to 0
 *
 *  @since 2.0.0
 */
@property (nonatomic, assign) NSTimeInterval requestTime;

/**
 *  The duration to use to send the fake response body. This is the
 *  actual value applied to a mocked network action during playing.
 *  It represents the time that elapses (or the speed with which) all
 *  the data for a network action is returned for a request. Defaults to 0.0.
 *
 *  @note if responseTime<0, it is interpreted as a download speed in KBps ( -200 => 200KB/s )
 *
 *  @since 2.0.0
 */
@property (nonatomic, assign) NSTimeInterval responseTime;

/**
 *  This value is derived from recordings made by BeKindRewind and can be used
 *  while playing mocked network actions. It is the time elapsed between the
 *  beginning of a network request and the NSURLResponse being received. If
 *  any of this data is missing (e.g. a recording being truncated) then
 *  this value will be 0.0
 *
 *  @since 2.0.0
 */
@property (nonatomic, assign, readonly) NSTimeInterval recordedRequestTime;

/**
 *  This value is derived from recordings made by BeKindRewind and can be used
 *  while playing mocked network actions. It is the total time elapsed for
 *  returning all the data associated with a network request, after the NSURLResponse
 *  is returned. If the response time cannot be calculated (e.g. a recording being
 *  truncated) then this value will be 0.0.
 *
 *  @note While the responseTime for a BKRResponseStub can be negative to represent
 *        speed, the recordedResponseTime will always be >= 0.
 *
 *  @note This will be 0.0 for a redirect because no data is returned during a redirect
 *
 *  @since 2.0.0
 */
@property (nonatomic, assign, readonly) NSTimeInterval recordedResponseTime;

#warning docs
@property (nonatomic, assign) NSInteger frameIndex; // this is NSNotFound by default

/**
 *  This extracts the scene identifier from information contained within the stub.
 *
 *  @return string that can be used to identify the BKRScene that is being mocked by the receiver.
 *
 *  @since 1.0.0
 */
- (NSString *)sceneIdentifier;

/**
 *  This checks whether the receiver stubs an error.
 *
 *  @return If `YES` then the receiver represents an errored 
 *          network action. If `NO` then the receiver represents a 
 *          network action that has responses and possibly data.
 *
 *  @since 1.0.0
 */
- (BOOL)isError;

/**
 *  This checks whether the receiver stubs a redirect.
 *
 *  @return If `YES` then the receiver represents an redirect to a
 *          network action. If `NO` then the receiver represents a
 *          network action that has either responses or an error.
 *
 *  @since 1.0.0
 */
- (BOOL)isRedirect;

@end

NS_ASSUME_NONNULL_END
