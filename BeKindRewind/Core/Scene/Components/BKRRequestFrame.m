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
@end

@implementation BKRRequestFrame

- (void)addRequest:(NSURLRequest *)request {
    self.HTTPBody = request.HTTPBody;
    self.HTTPShouldHandleCookies = request.HTTPShouldHandleCookies;
    self.HTTPShouldUsePipelining = request.HTTPShouldUsePipelining;
    self.allHTTPHeaderFields = request.allHTTPHeaderFields;
    self.HTTPMethod = request.HTTPMethod;
    self.URL = request.URL;
    self.timeoutInterval = request.timeoutInterval;
    self.allowsCellularAccess = request.allowsCellularAccess;
}

- (NSDictionary *)plistDictionary {
    NSDictionary *superDict = [super plistDictionary];
    NSMutableDictionary *plistDict = [NSMutableDictionary dictionaryWithDictionary:superDict];
    NSDictionary *dict =@{
                          @"URL": self.URL.absoluteString,
                          @"timeoutInterval": @(self.timeoutInterval),
                          @"allowsCellularAccess": @(self.allowsCellularAccess),
                          @"HTTPShouldHandleCookies": @(self.HTTPShouldHandleCookies),
                          @"HTTPShouldUsePipelining": @(self.HTTPShouldUsePipelining)
                          };
    [plistDict addEntriesFromDictionary:dict];
    if (self.HTTPMethod) {
        plistDict[@"HTTPMethod"] = self.HTTPMethod;
    }
    if (self.HTTPBody) {
        plistDict[@"HTTPBody"] = self.HTTPBody;
    }
    if (self.allHTTPHeaderFields) {
        plistDict[@"allHTTPHeaderFields"] = self.allHTTPHeaderFields;
    }
    return [[NSDictionary alloc] initWithDictionary:plistDict copyItems:YES];
}

@end
