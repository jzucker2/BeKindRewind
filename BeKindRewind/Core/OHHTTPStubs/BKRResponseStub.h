//
//  BKRResponseStub.h
//  Pods
//
//  Created by Jordan Zucker on 3/10/16.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class OHHTTPStubsResponse;

/**
 *  This is used by BeKindRewind to mock a server response. This instance 
 *  contains everything necessary to stub the response using the OHHTTPStubs 
 *  framework.
 */
@interface BKRResponseStub : NSObject

/**
 *  This is a convenience initializer that is used by OHHTTPStubs to mock a 
 *  network response that does not end in an error.
 *
 *  @param data       this is the information returned for the request that is being mocked.
 *  @param statusCode this is the HTTP code returned for the request that is being mocked.
 *  @param headers    this is the headers returned for the request that is being mocked.
 *
 *  @return newly initialized instance of BKRResponseStub
 */
+ (instancetype)responseWithData:(nullable NSData *)data statusCode:(int)statusCode headers:(nullable NSDictionary *)headers;

/**
 *  This is a convenience initializer that is used by OHHTTPStubs to mock a network
 *  response that ends in an error.
 *
 *  @param error this is everything associated with the failed or error-ed network request.
 *
 *  @return newly initialized instance of BKRResponseStub
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
 */
+ (instancetype)responseWithStubsResponse:(OHHTTPStubsResponse *)response;

/**
 *  This is provided to OHHTTPStubs that is delivered for the mocked network action.
 */
@property (nonatomic, strong, readonly, nullable) NSInputStream *inputStream;

/**
 *  This is the size of the data to mock the network action.
 */
@property (nonatomic, assign, readonly) unsigned long long dataSize;

/**
 *  This is the status code used for the network response.
 */
@property (nonatomic, assign, readonly) int statusCode;

/**
 *  This is a dictionary of headers associated with the network action.
 */
@property (nonatomic, strong, readonly, nullable) NSDictionary *headers;

/**
 *  This property determines whether the response is an error or a 
 *  network action. If this is not nil then all other properties are 
 *  ignored and only this is used to mock the network action.
 */
@property (nonatomic, strong, readonly, nullable) NSError *error;

/**
 *  This extracts the scene identifier from information contained within the stub.
 *
 *  @return string that can be used to identify the BKRScene that is being mocked by the receiver.
 */
- (NSString *)sceneIdentifier;

/**
 *  This checks whether the receiver stubs an error.
 *
 *  @return If `YES` then the receiver represents an errored 
 *          network action. If `NO` then the receiver represents a 
 *          network action that has responses and possibly data.
 */
- (BOOL)isError;

/**
 *  This checks whether the receiver stubs a redirect.
 *
 *  @return If `YES` then the receiver represents an redirect to a
 *          network action. If `NO` then the receiver represents a
 *          network action that has either responses or an error.
 */
- (BOOL)isRedirect;

@end

NS_ASSUME_NONNULL_END
