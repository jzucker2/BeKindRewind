//
//  BKRRequestFrame.m
//  Pods
//
//  Created by Jordan Zucker on 1/20/16.
//
//

#import "BKRRequestFrame.h"

@interface BKRRequestFrame ()
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

@implementation BKRRequestFrame

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

- (NSDictionary *)plistRepresentation {
    NSDictionary *superDict = [super plistRepresentation];
    NSMutableDictionary *plistDict = [NSMutableDictionary dictionaryWithDictionary:superDict];
    NSDictionary *dict =@{
                          @"URL": self.URL.absoluteString,
                          @"timeoutInterval": @(self.timeoutInterval),
                          @"allowsCellularAccess": @(self.allowsCellularAccess)
                          };
    [plistDict addEntriesFromDictionary:dict];
    if (self.HTTPMethod) {
        plistDict[@"HTTPMethod"] = self.HTTPMethod;
    }
    if (self.HTTPBody) {
        plistDict[@"HTTPBody"] = self.HTTPBody;
    }
    if (self.HTTPShouldHandleCookies) {
        plistDict[@"HTTPShouldHandleCookies"] = @(self.HTTPShouldHandleCookies);
    }
    if (self.HTTPShouldUsePipelining) {
        plistDict[@"HTTPShouldUsePipelining"] = @(self.HTTPShouldUsePipelining);
    }
    if (self.allHTTPHeaderFields) {
        plistDict[@"allHTTPHeaderFields"] = self.allHTTPHeaderFields;
    }
    if (self.isOriginalRequest) {
        plistDict[@"isOriginalRequest"] = @(self.isOriginalRequest);
    }
    return [[NSDictionary alloc] initWithDictionary:plistDict copyItems:YES];
}

@end
