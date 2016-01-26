//
//  BKROHHTTPStubsWrapper.m
//  Pods
//
//  Created by Jordan Zucker on 1/24/16.
//
//

#import <OHHTTPStubs/OHHTTPStubs.h>
#import "BKROHHTTPStubsWrapper.h"
#import "BKRPlayableScene.h"

@implementation BKROHHTTPStubsWrapper

+ (void)removeAllStubs {
    [OHHTTPStubs removeAllStubs];
}

+ (OHHTTPStubsResponse *)_responseForScene:(BKRPlayableScene *)scene {
    if (scene.responseError) {
        return [OHHTTPStubsResponse responseWithError:scene.responseError];
    }
    return [OHHTTPStubsResponse responseWithData:scene.responseData statusCode:(int)scene.responseStatusCode headers:scene.responseHeaders];
}

+ (void)stubRequestPassingTest:(BKRStubsTestBlock)testBlock withStubResponse:(BKRStubsResponseBlock)responseBlock {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return testBlock(request);
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [self _responseForScene:responseBlock(request)];
    }];
}

@end
