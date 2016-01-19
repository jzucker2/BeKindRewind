//
//  BKRRequest.m
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import "BKRRequest.h"

@interface BKRRequest ()
@property (nonatomic, copy) NSURLRequest *request;
@end

@implementation BKRRequest

//- (instancetype)initWithRequest:(NSURLRequest *)request {
//    self = [super init];
//    if (self) {
//        _request = request;
//    }
//    return self;
//}
//
//+ (instancetype)frameWithRequest:(NSURLRequest *)request {
//    return [[self alloc] initWithRequest:request];
//}

- (void)addRequest:(NSURLRequest *)request {
    self.request = request;
}

@end
