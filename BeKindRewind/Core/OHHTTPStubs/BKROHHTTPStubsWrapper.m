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
    NSLog(@"%@: before %s", self, __PRETTY_FUNCTION__);
    [OHHTTPStubs removeAllStubs];
    NSLog(@"%@: after %s", self, __PRETTY_FUNCTION__);
}

+ (OHHTTPStubsResponse *)_responseForStub:(BKRResponseStub *)responseStub {
    OHHTTPStubsResponse *mockingResponse = nil;
    if (responseStub.isError) {
        mockingResponse = [OHHTTPStubsResponse responseWithError:responseStub.error];
    } else {
        mockingResponse = [[OHHTTPStubsResponse alloc] initWithInputStream:responseStub.inputStream dataSize:responseStub.dataSize statusCode:responseStub.statusCode headers:responseStub.headers];
    }
    if (
        (responseStub.requestTime != 0) ||
        (responseStub.responseTime != 0)
        ) {
        mockingResponse.requestTime = responseStub.requestTime;
        mockingResponse.responseTime = responseStub.responseTime;
    }
    return mockingResponse;
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
    if (stubActivationBlock) {
        [OHHTTPStubs onStubActivation:^(NSURLRequest * _Nonnull request, id<OHHTTPStubsDescriptor>  _Nonnull stub, OHHTTPStubsResponse * _Nonnull responseStub) {
            return stubActivationBlock(request, [BKRResponseStub responseWithStubsResponse:responseStub]);
        }];
    } else {
        [OHHTTPStubs onStubActivation:nil];
    }
}

+ (void)onStubRedirectResponse:(BKRStubRedirectBlock)stubRedirectBlock {
    if (stubRedirectBlock) {
        [OHHTTPStubs onStubRedirectResponse:^(NSURLRequest * _Nonnull request, NSURLRequest * _Nonnull redirectRequest, id<OHHTTPStubsDescriptor>  _Nonnull stub, OHHTTPStubsResponse * _Nonnull responseStub) {
            return stubRedirectBlock(request, redirectRequest, [BKRResponseStub responseWithStubsResponse:responseStub]);
        }];
    } else {
        [OHHTTPStubs onStubRedirectResponse:nil];
    }
}

+ (void)onStubCompletion:(BKRStubCompletionBlock)stubCompletionBlock {
    if (stubCompletionBlock) {
        [OHHTTPStubs afterStubFinish:^(NSURLRequest * _Nonnull request, id<OHHTTPStubsDescriptor>  _Nonnull stub, OHHTTPStubsResponse * _Nonnull responseStub, NSError * _Nonnull error) {
            return stubCompletionBlock(request, [BKRResponseStub responseWithStubsResponse:responseStub], error);
        }];
    } else {
        [OHHTTPStubs afterStubFinish:nil];
    }
    
}

@end
