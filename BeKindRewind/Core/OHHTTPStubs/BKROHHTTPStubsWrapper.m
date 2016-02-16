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

@implementation BKROHHTTPStubsWrapper

+ (void)removeAllStubs {
    [OHHTTPStubs removeAllStubs];
}

+ (OHHTTPStubsResponse *)_responseForScene:(BKRScene *)scene {
    if (scene.responseError) {
        return [OHHTTPStubsResponse responseWithError:scene.responseError];
    }
    return [OHHTTPStubsResponse responseWithData:scene.responseData statusCode:(int)scene.responseStatusCode headers:scene.responseHeaders];
}

+ (BOOL)hasStubs {
    return ([OHHTTPStubs allStubs].count != 0);
}

+ (void)stubRequestPassingTest:(BKRStubsTestBlock)testBlock withStubResponse:(BKRStubsResponseBlock)responseBlock {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return testBlock(request);
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [self _responseForScene:responseBlock(request)];
    }];
}

+ (void)setEnabled:(BOOL)enabled {
    [OHHTTPStubs setEnabled:enabled];
}

@end
