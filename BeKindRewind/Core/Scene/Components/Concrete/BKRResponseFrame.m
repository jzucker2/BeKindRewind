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

- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary {
    self = [super initFromPlistDictionary:dictionary];
    if (self) {
        _URL = [NSURL URLWithString:dictionary[@"URL"]];
        _MIMEType = dictionary[@"MIMEType"];
    }
    if (dictionary[@"statusCode"]) {
        _statusCode = [dictionary[@"statusCode"] integerValue];
        _allHeaderFields = [[NSDictionary alloc] initWithDictionary:dictionary[@"allHeaderFields"] copyItems:YES];
    }
    return self;
}

- (NSString *)debugDescription {
    NSString *superDescription = [super debugDescription];
    return [NSString stringWithFormat:@"%@, status: %ld, allHeaderFields: %@", superDescription, (long)self.statusCode, self.allHeaderFields];
}

@end
