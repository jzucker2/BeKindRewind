//
//  BKRRequestFrame.h
//  Pods
//
//  Created by Jordan Zucker on 1/20/16.
//
//

#import "BKRFrame.h"
#import "BKRPlistSerializing.h"

@interface BKRRequestFrame : BKRFrame <BKRPlistSerializing>

@property (nonatomic, copy, readonly) NSData *HTTPBody;
@property (nonatomic, readonly) BOOL HTTPShouldHandleCookies;
@property (nonatomic, readonly) BOOL HTTPShouldUsePipelining;
@property (nonatomic, copy, readonly) NSDictionary *allHTTPHeaderFields;
@property (nonatomic, copy, readonly) NSString *HTTPMethod;
@property (nonatomic, copy, readonly) NSURL *URL;
@property (nonatomic, readonly) NSTimeInterval timeoutInterval;
@property (nonatomic, readonly) BOOL allowsCellularAccess;

- (void)addRequest:(NSURLRequest *)request;

@end
