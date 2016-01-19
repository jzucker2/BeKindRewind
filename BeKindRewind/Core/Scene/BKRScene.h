//
//  BKRScene.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <Foundation/Foundation.h>

@class BKRData;
@class BKRRequest;
@class BKRResponse;
@interface BKRScene : NSObject

- (instancetype)initWithTask:(NSURLSessionTask *)task;
+ (instancetype)sceneWithTask:(NSURLSessionTask *)task;

@property (nonatomic, copy) NSString *uniqueIdentifier;
- (void)addData:(NSData *)data;
- (void)addRequest:(NSURLRequest *)request;
- (void)addResponse:(NSURLResponse *)response;
- (void)addError:(NSError *)error;
//@property (nonatomic, strong) BKRData *data;
//@property (nonatomic, strong) BKRRequest *request;
//@property (nonatomic, strong) BKRResponse *response;

@end
