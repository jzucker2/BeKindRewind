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

+ (OHHTTPStubsResponse *)responseForScene:(BKRPlayableScene *)scene {
    return [OHHTTPStubsResponse responseWithData:scene.responseData statusCode:(int)scene.responseStatusCode headers:scene.responseHeaders];
}

@end
