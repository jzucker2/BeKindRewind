//
//  BKRRequest.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import "BKRFrame.h"

@interface BKRRequest : BKRFrame

@property (nonatomic, copy, readonly) NSData *HTTPBody;
@property (nonatomic, readonly) BOOL HTTPShouldHandleCookies;
@property (nonatomic, readonly) BOOL HTTPShouldUsePipelining;
@property (nonatomic, copy, readonly) NSDictionary *allHTTPHeaderFields;
@property (nonatomic, copy, readonly) NSString *HTTPMethod;
@property (nonatomic, copy, readonly) NSURL *URL;
@property (nonatomic, readonly) NSTimeInterval timeoutInterval;
@property (nonatomic, readonly) BOOL allowsCellularAccess;
@property (nonatomic, readonly) BOOL isOriginalRequest;

- (void)addRequest:(NSURLRequest *)request;
- (void)addRequest:(NSURLRequest *)request isOriginal:(BOOL)isOriginalRequest;

@end
