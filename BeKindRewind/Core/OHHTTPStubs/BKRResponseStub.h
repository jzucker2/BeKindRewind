//
//  BKRResponseStub.h
//  Pods
//
//  Created by Jordan Zucker on 3/10/16.
//
//

#import <Foundation/Foundation.h>

@interface BKRResponseStub : NSObject
@property (nonatomic, strong, readonly, nullable) NSData *data;
@property (nonatomic, assign, readonly) int statusCode;
@property (nonatomic, strong, readonly, nullable) NSDictionary *headers;
@property (nonatomic, strong, readonly, nullable) NSError *error; // if there is not nil then the other things are ignored
+ (instancetype)responseWithData:(NSData *)data statusCode:(int)statusCode headers:(NSDictionary *)headers;
+ (instancetype)responseWithError:(NSError *)error;
@end
