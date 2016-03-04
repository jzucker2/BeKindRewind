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
 */
@interface BKRRequestFrame : BKRFrame <BKRPlistSerializing>

/**
 *  This data represents the data uploaded with a NSURLRequest
 */
@property (nonatomic, copy, readonly) NSData *HTTPBody;

/**
 *  Whether cookies should be handled during the operation of the request
 */
@property (nonatomic, readonly) BOOL HTTPShouldHandleCookies;

/**
 *  Whether pipelining should be used during the operation of the request
 */
@property (nonatomic, readonly) BOOL HTTPShouldUsePipelining;

/**
 *  All HTTP header fields in a dictionary used during the operation of the request. This is typically
 *  updated by the server in a NSURLSessionTask object's task.currentRequest
 */
@property (nonatomic, copy, readonly) NSDictionary *allHTTPHeaderFields;

/**
 *  The type of HTTP method associated with the request (GET, POST, PUT, etc.)
 */
@property (nonatomic, copy, readonly) NSString *HTTPMethod;

/**
 *  The URL associated with the request
 */
@property (nonatomic, copy, readonly) NSURL *URL;

/**
 *  The timeout of the request
 */
@property (nonatomic, readonly) NSTimeInterval timeoutInterval;

/**
 *  This determines whether the request will allow cellular access
 */
@property (nonatomic, readonly) BOOL allowsCellularAccess;

/**
 *  This breaks the URL of the request into easily parsed components
 */
@property (nonatomic, readonly) NSURLComponents *requestComponents;

/**
 *  The path of the URL used in this request
 */
@property (nonatomic, readonly) NSString *requestPath;

/**
 *  The host of the URL used in this request
 */
@property (nonatomic, readonly) NSString *requestHost;

/**
 *  The scheme of the URL used in this request
 */
@property (nonatomic, readonly) NSString *requestScheme;

/**
 *  The fragment of the URL used in this request
 */
@property (nonatomic, readonly) NSString *requestFragment;

/**
 *  An array of the query items from the URL used in this request
 */
@property (nonatomic, readonly) NSArray<NSURLQueryItem *> *requestQueryItems;

/**
 *  Add the request that this subclass of BKRFrame is meant to represent
 *
 *  @param request associated with network operation
 */
- (void)addRequest:(NSURLRequest *)request;

@end

@interface BKROriginalRequestFrame : BKRRequestFrame
@end

@interface BKRCurrentRequestFrame : BKRRequestFrame
@end
