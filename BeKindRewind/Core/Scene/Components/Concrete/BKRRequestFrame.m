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
@synthesize requestComponents = _requestComponents;

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

- (NSURLComponents *)requestComponents {
    if (!_requestComponents) {
        _requestComponents = [NSURLComponents componentsWithString:self.URL.absoluteString];
    }
    return _requestComponents;
}

- (NSArray<NSURLQueryItem *> *)requestQueryItems {
    return self.requestComponents.queryItems;
}

- (NSString *)requestFragment {
    return self.requestComponents.fragment;
}

- (NSString *)requestHost {
    return self.requestComponents.host;
}

- (NSString *)requestPath {
    return self.requestComponents.path;
}

- (NSString *)requestScheme {
    return self.requestComponents.scheme;
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

- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary {
    self = [super initFromPlistDictionary:dictionary];
    if (self) {
        _URL = [NSURL URLWithString:dictionary[@"URL"]];
        _timeoutInterval = [dictionary[@"timeoutInterval"] doubleValue];
        _allowsCellularAccess = [dictionary[@"allowsCellularAccess"] boolValue];
        _HTTPShouldHandleCookies = [dictionary[@"HTTPShouldHandleCookies"] boolValue];
        _HTTPShouldUsePipelining = [dictionary[@"HTTPShouldUsePipelining"] boolValue];
        if (dictionary[@"HTTPMethod"]) {
            _HTTPMethod = dictionary[@"HTTPMethod"];
        }
        if (dictionary[@"HTTPBody"]) {
            _HTTPBody = dictionary[@"HTTPBody"];
        }
        if (dictionary[@"allHTTPHeaderFields"]) {
            _allHTTPHeaderFields = [[NSDictionary alloc] initWithDictionary:dictionary[@"allHTTPHeaderFields"] copyItems:YES];
        }
    }
    return self;
}

@end
