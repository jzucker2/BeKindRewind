//
//  BKRResponse.m
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import "BKRResponse.h"

@interface BKRResponse ()
@property (nonatomic, copy) NSURLResponse *response;
@end

@implementation BKRResponse

//- (instancetype)initWithResponse:(NSURLResponse *)response {
//    self = [super init];
//    if (self) {
//        _response = response;
//    }
//    return self;
//}
//
//+ (instancetype)frameWithResponse:(NSURLResponse *)response {
//    return [[self alloc] initWithResponse:response];
//}

- (void)addResponse:(NSURLResponse *)response {
    self.response = response;
}

@end
