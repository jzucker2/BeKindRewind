//
//  BKRResponseStub.m
//  Pods
//
//  Created by Jordan Zucker on 3/10/16.
//
//

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

+ (instancetype)responseWithData:(NSData *)data statusCode:(int)statusCode headers:(NSDictionary *)headers {
    return [[self alloc] initWithData:data statusCode:statusCode headers:headers error:nil];
}

+ (instancetype)responseWithError:(NSError *)error {
    return [[self alloc] initWithData:nil statusCode:0 headers:nil error:error];
}

@end
