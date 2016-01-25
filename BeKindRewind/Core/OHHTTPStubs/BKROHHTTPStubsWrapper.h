//
//  BKROHHTTPStubsWrapper.h
//  Pods
//
//  Created by Jordan Zucker on 1/24/16.
//
//

#import <Foundation/Foundation.h>

@class BKRPlayableScene;
//@class OHHTTPStubsResponse;

typedef BOOL (^BKRStubsTestBlock)(NSURLRequest* _Nonnull request);
typedef BKRPlayableScene* (^BKRStubsResponseBlock)(NSURLRequest* _Nonnull request);

@interface BKROHHTTPStubsWrapper : NSObject

+ (void)removeAllStubs;

//+ (OHHTTPStubsResponse *)responseForScene:(BKRPlayableScene *)scene;

+ (void)stubRequestPassingTest:(BKRStubsTestBlock)testBlock withStubResponse:(BKRStubsResponseBlock)responseBlock;

@end
