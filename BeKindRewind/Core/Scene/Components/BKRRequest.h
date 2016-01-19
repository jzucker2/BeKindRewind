//
//  BKRRequest.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import "BKRFrame.h"

@interface BKRRequest : BKRFrame

//- (instancetype)initWithRequest:(NSURLRequest *)request;
//+ (instancetype)frameWithRequest:(NSURLRequest *)request;
- (void)addRequest:(NSURLRequest *)request;

@end
