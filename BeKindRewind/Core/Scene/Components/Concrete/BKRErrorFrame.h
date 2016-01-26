//
//  BKRErrorFrame.h
//  Pods
//
//  Created by Jordan Zucker on 1/25/16.
//
//

#import "BKRFrame.h"
#import "BKRPlistSerializing.h"

@interface BKRErrorFrame : BKRFrame <BKRPlistSerializing>

- (void)addError:(NSError *)error;
//- (NSError *)error;
//- (NSInteger)code;
//- (NSString *)domain;
//- (NSDictionary *)userInfo;
@property (nonatomic, readonly) NSError *error;
@property (nonatomic, readonly) NSInteger code;
@property (nonatomic, copy, readonly) NSString *domain;
@property (nonatomic, readonly) NSDictionary *userInfo;

@end
