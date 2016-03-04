//
//  BKRRedirectFrame.h
//  Pods
//
//  Created by Jordan Zucker on 3/4/16.
//
//

#import "BKRFrame.h"
#import "BKRPlistSerializing.h"

@class BKRRequestFrame;
@class BKRResponseFrame;
@interface BKRRedirectFrame : BKRFrame <BKRPlistSerializing>

- (void)addRequest:(NSURLRequest *)request;
- (void)addResponse:(NSURLResponse *)response;

@property (nonatomic, strong, readonly) BKRRequestFrame *requestFrame;
@property (nonatomic, strong, readonly) BKRResponseFrame *responseFrame;

@end
