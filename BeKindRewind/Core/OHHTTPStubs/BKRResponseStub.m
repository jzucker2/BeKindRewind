//
//  BKRResponseStub.m
//  Pods
//
//  Created by Jordan Zucker on 3/10/16.
//
//

#import <OHHTTPStubs/OHHTTPStubsResponse.h>
#import "BKRResponseStub.h"
#import "BKRScene.h"
#import "BKRConstants.h"

#pragma mark - Defines & Constants
const double BKRDownloadSpeed1KBPS  =-     8 / 8; // kbps -> KB/s
const double BKRDownloadSpeedSLOW   =-    12 / 8; // kbps -> KB/s
const double BKRDownloadSpeedGPRS   =-    56 / 8; // kbps -> KB/s
const double BKRDownloadSpeedEDGE   =-   128 / 8; // kbps -> KB/s
const double BKRDownloadSpeed3G     =-  3200 / 8; // kbps -> KB/s
const double BKRDownloadSpeed3GPlus =-  7200 / 8; // kbps -> KB/s
const double BKRDownloadSpeedWifi   =- 12000 / 8; // kbps -> KB/s

#pragma mark - Implementation

@interface BKRResponseStub ()
@property (nonatomic, assign, readwrite) int statusCode;
@property (nonatomic, strong, readwrite, nullable) NSDictionary *headers;
@property (nonatomic, strong, readwrite, nullable) NSError *error; // if there is not nil then the other things
@end

@implementation BKRResponseStub

- (instancetype)initWithData:(NSData *)data statusCode:(int)statusCode headers:(NSDictionary *)headers error:(NSError *)error {
    NSInputStream *inputStream = [NSInputStream inputStreamWithData:data?:[NSData data]];
    self = [self initWithInputStream:inputStream dataSize:data.length statusCode:statusCode headers:headers error:error];
    return self;
}

- (instancetype)initWithInputStream:(NSInputStream *)inputStream dataSize:(unsigned long long)dataSize statusCode:(int)statusCode headers:(NSDictionary *)headers error:(NSError *)error {
    self = [super init];
    if (self) {
        _inputStream = inputStream;
        _dataSize = dataSize;
        _statusCode = statusCode;
        _headers = headers;
        _error = error;
    }
    return self;
}

- (instancetype)initWithStubsResponse:(OHHTTPStubsResponse *)response {
    self = [self initWithInputStream:response.inputStream dataSize:response.dataSize statusCode:response.statusCode headers:response.httpHeaders error:response.error];
    if (self) {
        _requestTime = response.requestTime;
        _responseTime = response.responseTime;
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

- (BOOL)isError {
    return (self.error != nil);
}

- (BOOL)isRedirect {
    NSDictionary *headers = self.headers;
    BOOL hasRedirectLocationHeaderKey = (
                                         headers &&
                                         headers[@"Location"]
                                         );
    BOOL hasRedirectStatusCode = (
                                  (self.statusCode > 300) &&
                                  (self.statusCode < 400)
                                  );
    return (
            hasRedirectLocationHeaderKey &&
            hasRedirectStatusCode
            );
}

- (NSString *)sceneIdentifier {
    NSString *sceneUUID = nil;
    if (self.isError) {
        NSDictionary *errorUserInfo = self.error.userInfo;
        sceneUUID = errorUserInfo[kBKRSceneUUIDKey];
    }
    if (sceneUUID) {
        return sceneUUID;
    }
    NSDictionary *headers = self.headers;
    sceneUUID = headers[kBKRSceneUUIDKey];
    return sceneUUID;
}

- (void)setRequestTime:(NSTimeInterval)requestTime {
    NSAssert(requestTime >= 0, @"Invalid Request Time (%f) for BeKindRewind. Request time must be greater than or equal to zero", requestTime);
    _requestTime = requestTime;
}

@end
