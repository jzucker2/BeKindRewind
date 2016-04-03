//
//  BKRRequestFrame.h
//  Pods
//
//  Created by Jordan Zucker on 1/20/16.
//
//

#import "BKRFrame.h"
#import "BKRPlistSerializing.h"

/**
 *  Concrete subclass of BKRFrame representing a BKRRequestFrame associated with a network operation.
 *  All of the important settings and configurations of a NSURLRequest are stored for proper debugging
 *  and stubbing.
 *
 *  @since 1.0.0
 */
@interface BKRRequestFrame : BKRFrame <BKRPlistSerializing>

/**
 *  This data represents the data uploaded with a NSURLRequest
 *
 *  @since 1.0.0
 */
@property (nonatomic, copy, readonly) NSData *HTTPBody;

/**
 *  Whether cookies should be handled during the operation of the request
 *
 *  @since 1.0.0
 */
@property (nonatomic, readonly) BOOL HTTPShouldHandleCookies;

/**
 *  Whether pipelining should be used during the operation of the request
 *
 *  @since 1.0.0
 */
@property (nonatomic, readonly) BOOL HTTPShouldUsePipelining;

/**
 *  All HTTP header fields in a dictionary used during the operation of the request. This is typically
 *  updated by the server in a NSURLSessionTask object's task.currentRequest
 *
 *  @since 1.0.0
 */
@property (nonatomic, copy, readonly) NSDictionary *allHTTPHeaderFields;

/**
 *  The type of HTTP method associated with the request (GET, POST, PUT, etc.)
 *
 *  @since 1.0.0
 */
@property (nonatomic, copy, readonly) NSString *HTTPMethod;

/**
 *  The URL associated with the request
 *
 *  @since 1.0.0
 */
@property (nonatomic, copy, readonly) NSURL *URL;

/**
 *  The absoluteString of the URL
 *
 *  @since 1.0.0
 */
@property (nonatomic, copy, readonly) NSString *URLAbsoluteString;

/**
 *  The timeout of the request
 *
 *  @since 1.0.0
 */
@property (nonatomic, readonly) NSTimeInterval timeoutInterval;

/**
 *  This determines whether the request will allow cellular access
 *
 *  @since 1.0.0
 */
@property (nonatomic, readonly) BOOL allowsCellularAccess;

/**
 *  This breaks the URL of the request into easily parsed components
 *
 *  @since 1.0.0
 */
@property (nonatomic, readonly) NSURLComponents *requestComponents;

/**
 *  The path of the URL used in this request
 *
 *  @since 1.0.0
 */
@property (nonatomic, readonly) NSString *requestPath;

/**
 *  The host of the URL used in this request
 *
 *  @since 1.0.0
 */
@property (nonatomic, readonly) NSString *requestHost;

/**
 *  The scheme of the URL used in this request
 *
 *  @since 1.0.0
 */
@property (nonatomic, readonly) NSString *requestScheme;

/**
 *  The fragment of the URL used in this request
 *
 *  @since 1.0.0
 */
@property (nonatomic, readonly) NSString *requestFragment;

/**
 *  An array of the query items from the URL used in this request
 *
 *  @since 1.0.0
 */
@property (nonatomic, readonly) NSArray<NSURLQueryItem *> *requestQueryItems;

/**
 *  Add the request that this subclass of BKRFrame is meant to represent
 *
 *  @param request associated with network operation
 *
 *  @since 1.0.0
 */
- (void)addRequest:(NSURLRequest *)request;

@end

/**
 *  This subclass represents the NSURLRequest associated with the `originalRequest` 
 *  property of a NSURLSessionTask instance.
 *
 *  @since 1.0.0
 */
@interface BKROriginalRequestFrame : BKRRequestFrame
@end

/**
 *  This subclass represents the NSURLRequest associated with the `currentRequest`
 *  property of a NSURLSessionTask instance.
 *
 *  @since 1.0.0
 */
@interface BKRCurrentRequestFrame : BKRRequestFrame
@end
