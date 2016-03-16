//
//  BKRResponseStub.h
//  Pods
//
//  Created by Jordan Zucker on 3/10/16.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class OHHTTPStubsResponse;
@interface BKRResponseStub : NSObject
@property (nonatomic, strong, readonly, nullable) NSInputStream *inputStream;
@property (nonatomic, assign, readonly) unsigned long long dataSize;
@property (nonatomic, assign, readonly) int statusCode;
@property (nonatomic, strong, readonly, nullable) NSDictionary *headers;
@property (nonatomic, strong, readonly, nullable) NSError *error; // if there is not nil then the other things are ignored
+ (instancetype)responseWithData:(nullable NSData *)data statusCode:(int)statusCode headers:(nullable NSDictionary *)headers;
+ (instancetype)responseWithError:(NSError *)error;
+ (instancetype)responseWithStubsResponse:(OHHTTPStubsResponse *)response;
- (NSString *)sceneIdentifier;
- (BOOL)isError;
@end

NS_ASSUME_NONNULL_END
