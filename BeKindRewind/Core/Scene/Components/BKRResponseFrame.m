//
//  BKRResponseFrame.m
//  Pods
//
//  Created by Jordan Zucker on 1/20/16.
//
//

#import "BKRResponseFrame.h"

@interface BKRResponseFrame ()
@property (nonatomic, copy, readwrite) NSURL *URL;
@property (nonatomic, copy, readwrite) NSString *MIMEType;
@property (nonatomic, readwrite) NSInteger statusCode;
@property (nonatomic, copy, readwrite) NSDictionary *allHeaderFields;
@end

@implementation BKRResponseFrame

- (instancetype)initWithTask:(NSURLSessionTask *)task {
    self = [super initWithTask:task];
    if (self) {
        _statusCode = -1;
    }
    return self;
}

- (void)addResponse:(NSURLResponse *)response {
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        self.statusCode = httpResponse.statusCode;
        self.allHeaderFields = httpResponse.allHeaderFields;
    }
    self.URL = response.URL;
    self.MIMEType = response.MIMEType;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dict = [@{
                                   @"URL" : self.URL.absoluteString,
                                   @"MIMEType" : self.MIMEType,
                                   } mutableCopy];
    if (self.statusCode >= 0) {
        dict[@"statusCode"] = @(self.statusCode);
        dict[@"allHeaderFields"] = self.allHeaderFields;
    }
    return [[NSDictionary alloc] initWithDictionary:dict copyItems:YES];
}

- (NSDictionary *)plistDictionary {
    NSDictionary *superDict = [super plistDictionary];
    NSMutableDictionary *plistDict = [NSMutableDictionary dictionaryWithDictionary:superDict];
    NSDictionary *dict = @{
                           @"URL": self.URL.absoluteString,
                           @"MIMEType": self.MIMEType.copy
                           };
    [plistDict addEntriesFromDictionary:dict];
    if (self.statusCode >= 0) {
        plistDict[@"statusCode"] = @(self.statusCode);
        plistDict[@"allHeaderFields"] = [[NSDictionary alloc] initWithDictionary:self.allHeaderFields copyItems:YES];
    }
    return [[NSDictionary alloc] initWithDictionary:plistDict copyItems:YES];
}

@end
