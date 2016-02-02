//
//  BKROHHTTPStubsWrapper.h
//  Pods
//
//  Created by Jordan Zucker on 1/24/16.
//
//

#import <Foundation/Foundation.h>

@class BKRPlayableScene;

typedef BOOL (^BKRStubsTestBlock)(NSURLRequest* _Nonnull request);
typedef BKRPlayableScene* __nonnull (^BKRStubsResponseBlock)(NSURLRequest* _Nonnull request);

@interface BKROHHTTPStubsWrapper : NSObject

+ (void)removeAllStubs;

+ (void)setEnabled:(BOOL)enabled;

+ (void)stubRequestPassingTest:(nonnull BKRStubsTestBlock)testBlock withStubResponse:(nonnull BKRStubsResponseBlock)responseBlock;

@end
