//
//  BKRResponseStub.m
//  Pods
//
//  Created by Jordan Zucker on 3/10/16.
//
//

#import <OHHTTPStubs/OHHTTPStubsResponse.h>
#import "BKRResponseStub.h"

@interface BKRResponseStub ()
@property (nonatomic, strong, readwrite, nullable) NSData *data;
@property (nonatomic, assign, readwrite) int statusCode;
@property (nonatomic, strong, readwrite, nullable) NSDictionary *headers;
@property (nonatomic, strong, readwrite, nullable) NSError *error; // if there is not nil then the other things
@end

@implementation BKRResponseStub

- (instancetype)initWithData:(NSData *)data statusCode:(int)statusCode headers:(NSDictionary *)headers error:(NSError *)error {
    self = [super init];
    if (self) {
        _data = data;
        _statusCode = statusCode;
        _headers = headers;
        _error = error;
    }
    return self;
}

- (instancetype)initWithStubsResponse:(OHHTTPStubsResponse *)response {
    self = [self initWithData:nil statusCode:response.statusCode headers:response.httpHeaders error:response.error];
    if (self) {
        
    }
    return self;
}

+ (instancetype)responseWithStubsResponse:(OHHTTPStubsResponse *)response {
    return [[self alloc] initWithStubsResponse:response];
}

+ (instancetype)responseWithData:(NSData *)data statusCode:(int)statusCode headers:(NSDictionary *)headers {
    return [[self alloc] initWithData:data statusCode:statusCode headers:headers error:nil];
}

+ (instancetype)responseWithError:(NSError *)error {
    return [[self alloc] initWithData:nil statusCode:0 headers:nil error:error];
}

@end
