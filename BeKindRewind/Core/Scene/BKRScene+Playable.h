//
//  BKRScene+Playable.h
//  Pods
//
//  Created by Jordan Zucker on 2/12/16.
//
//

#import "BKRScene.h"
#import "BKRPlistSerializing.h"

@class BKRResponseStub;
//@class BKRSceneResponseStub;

/**
 *  This category handles the data associated with a network
 *  request and is intended to be used for stubbing.
 */
@interface BKRScene (Playable) <BKRPlistDeserializer>

- (NSUInteger)numberOfRedirects;
- (BOOL)hasRedirects;
- (BKRRequestFrame *)requestFrameForRemainingRedirect:(NSUInteger)remainingRedirect;
- (NSString *)originalRequestURLAbsoluteString;
- (BKRRedirectFrame *)redirectFrameForRemainingRedirect:(NSUInteger)remainingRedirect;
- (NSString *)requestURLAbsoluteStringForRemainingRedirect:(NSUInteger)remainingRedirect;
- (BKRResponseStub *)finalResponseStub;
- (BKRResponseStub *)responseStubForRemainingRedirect:(NSUInteger)remainingRedirect;
- (BOOL)hasFinalResponseStubForRequest:(NSURLRequest *)request;
- (BOOL)hasRedirectResponseStubForRemainingRequest:(NSURLRequest *)request;
- (BOOL)hasResponseForRequest:(NSURLRequest *)request;

///**
// *  Data associated with a network request
// *
// *  @return object representing serialized data returned from the network request
// */
//- (NSData *)responseData;
//
///**
// *  Status code returned from server
// *
// *  @return integer value for HTTP status code
// */
//- (NSInteger)responseStatusCode;
//
///**
// *  Headers contained in server response
// *
// *  @return headers as dictionary
// */
//- (NSDictionary *)responseHeaders;
//
///**
// *  Error returned representing any potential networking issues
// *
// *  @return object should contain the elements included in a
// *  NSURLErrorDomain error
// */
//- (NSError *)responseError;

@end
