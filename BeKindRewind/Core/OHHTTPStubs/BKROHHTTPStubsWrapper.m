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
    if (responseStub.isError) {
        return [OHHTTPStubsResponse responseWithError:responseStub.error];
    }
    return [[OHHTTPStubsResponse alloc] initWithInputStream:responseStub.inputStream dataSize:responseStub.dataSize statusCode:responseStub.statusCode headers:responseStub.headers];
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

+ (void)onStubActivation:(BKRStubActivationBlock)stubActivationBlock {
    [OHHTTPStubs onStubActivation:^(NSURLRequest * _Nonnull request, id<OHHTTPStubsDescriptor>  _Nonnull stub, OHHTTPStubsResponse * _Nonnull responseStub) {
//        if (stubActivationBlock) {
//            return stubActivationBlock(request, [BKRResponseStub responseWithStubsResponse:responseStub]);
//        }
        return stubActivationBlock(request, [BKRResponseStub responseWithStubsResponse:responseStub]);
    }];
}

+ (void)onStubRedirectResponse:(BKRStubRedirectBlock)stubRedirectBlock {
    [OHHTTPStubs onStubRedirectResponse:^(NSURLRequest * _Nonnull request, NSURLRequest * _Nonnull redirectRequest, id<OHHTTPStubsDescriptor>  _Nonnull stub, OHHTTPStubsResponse * _Nonnull responseStub) {
        return stubRedirectBlock(request, redirectRequest, [BKRResponseStub responseWithStubsResponse:responseStub]);
    }];
}

+ (void)onStubCompletion:(BKRStubCompletionBlock)stubCompletionBlock {
    [OHHTTPStubs afterStubFinish:^(NSURLRequest * _Nonnull request, id<OHHTTPStubsDescriptor>  _Nonnull stub, OHHTTPStubsResponse * _Nonnull responseStub, NSError * _Nonnull error) {
        return stubCompletionBlock(request, [BKRResponseStub responseWithStubsResponse:responseStub], error);
    }];
}

@end
