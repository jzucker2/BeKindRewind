//
//  BKRResponse.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import "BKRFrame.h"

@interface BKRResponse : BKRFrame

//- (instancetype)initWithResponse:(NSURLResponse *)response;
//+ (instancetype)frameWithResponse:(NSURLResponse *)response;
- (void)addResponse:(NSURLResponse *)response;
- (NSInteger)statusCode;
- (NSDictionary *)headers;

@end
