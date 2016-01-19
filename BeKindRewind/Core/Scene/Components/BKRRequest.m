//
//  BKRRequest.m
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import "BKRRequest.h"

@interface BKRRequest ()
@property (nonatomic, copy, readwrite) NSData *HTTPBody;
@property (nonatomic, readwrite) BOOL HTTPShouldHandleCookies;
@property (nonatomic, readwrite) BOOL HTTPShouldUsePipelining;
@property (nonatomic, copy, readwrite) NSDictionary *allHTTPHeaderFields;
@property (nonatomic, copy, readwrite) NSString *HTTPMethod;
@property (nonatomic, copy, readwrite) NSURL *URL;
@property (nonatomic, readwrite) NSTimeInterval timeoutInterval;
@property (nonatomic, readwrite) BOOL allowsCellularAccess;
@property (nonatomic, readwrite) BOOL isOriginalRequest;
@end

@implementation BKRRequest

- (void)addRequest:(NSURLRequest *)request isOriginal:(BOOL)isOriginalRequest {
    self.HTTPBody = request.HTTPBody;
    self.HTTPShouldHandleCookies = request.HTTPShouldHandleCookies;
    self.HTTPShouldUsePipelining = request.HTTPShouldUsePipelining;
    self.allHTTPHeaderFields = request.allHTTPHeaderFields;
    self.HTTPMethod = request.HTTPMethod;
    self.URL = request.URL;
    self.timeoutInterval = request.timeoutInterval;
    self.allowsCellularAccess = request.allowsCellularAccess;
    self.isOriginalRequest = isOriginalRequest;
}

- (void)addRequest:(NSURLRequest *)request {
    [self addRequest:request isOriginal:NO];
}

@end
