//
//  BKRResponse.m
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import "BKRResponse.h"

@interface BKRResponse ()
//@property (nonatomic, copy) NSURLResponse *response;
@property (nonatomic, copy, readwrite) NSURL *URL;
@property (nonatomic, copy, readwrite) NSString *MIMEType;
@property (nonatomic, readwrite) NSInteger statusCode;
@property (nonatomic, copy, readwrite) NSDictionary *allHeaderFields;
@end

@implementation BKRResponse

//- (instancetype)initWithResponse:(NSURLResponse *)response {
//    self = [super init];
//    if (self) {
//        _response = response;
//    }
//    return self;
//}
//
//+ (instancetype)frameWithResponse:(NSURLResponse *)response {
//    return [[self alloc] initWithResponse:response];
//}

- (instancetype)initWithTask:(NSURLSessionTask *)task {
    self = [super initWithTask:task];
    if (self) {
        _statusCode = -1;
    }
    return self;
}

- (void)addResponse:(NSURLResponse *)response {
//    self.response = response;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        self.statusCode = httpResponse.statusCode;
        self.allHeaderFields = httpResponse.allHeaderFields;
    }
    self.URL = response.URL;
    self.MIMEType = response.MIMEType;
}

@end
