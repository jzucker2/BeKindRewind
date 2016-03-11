//
//  BKRResponseStub.h
//  Pods
//
//  Created by Jordan Zucker on 3/10/16.
//
//

#import <Foundation/Foundation.h>

@class OHHTTPStubsResponse;
@interface BKRResponseStub : NSObject
@property (nonatomic, strong, readonly, nullable) NSInputStream *inputStream;
@property (nonatomic, assign, readonly) unsigned long long dataSize;
@property (nonatomic, assign, readonly) int statusCode;
@property (nonatomic, strong, readonly, nullable) NSDictionary *headers;
@property (nonatomic, strong, readonly, nullable) NSError *error; // if there is not nil then the other things are ignored
+ (instancetype)responseWithData:(NSData *)data statusCode:(int)statusCode headers:(NSDictionary *)headers;
+ (instancetype)responseWithError:(NSError *)error;
+ (instancetype)responseWithStubsResponse:(OHHTTPStubsResponse *)response;
@end

@class BKRScene;

@interface BKRSceneResponseStub : NSObject

+ (instancetype)responseWithScene:(BKRScene *)scene responseStub:(BKRResponseStub *)responseStub;

@property (nonatomic, strong, readonly) BKRScene *scene;
@property (nonatomic, strong, readonly) BKRResponseStub *responseStub;

@end
