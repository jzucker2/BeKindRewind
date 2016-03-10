//
//  BKROHHTTPStubsWrapper.m
//  Pods
//
//  Created by Jordan Zucker on 1/24/16.
//
//

#import <OHHTTPStubs/OHHTTPStubs.h>
#import "BKROHHTTPStubsWrapper.h"
#import "BKRScene+Playable.h"
#import "BKRResponseStub.h"

@implementation BKROHHTTPStubsWrapper

+ (void)removeAllStubs {
    [OHHTTPStubs removeAllStubs];
}

+ (OHHTTPStubsResponse *)_responseForStub:(BKRResponseStub *)responseStub {
    if (responseStub.error) {
        return [OHHTTPStubsResponse responseWithError:responseStub.error];
    }
    return [OHHTTPStubsResponse responseWithData:responseStub.data statusCode:(int)responseStub.statusCode headers:responseStub.headers];
}

+ (BOOL)hasStubs {
    return ([OHHTTPStubs allStubs].count != 0);
}

+ (void)stubRequestPassingTest:(BKRStubsTestBlock)testBlock withStubResponse:(BKRStubsResponseBlock)responseBlock {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return testBlock(request);
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [self _responseForStub:responseBlock(request)];
    }];
}

+ (void)setEnabled:(BOOL)enabled {
    [OHHTTPStubs setEnabled:enabled];
}

@end
