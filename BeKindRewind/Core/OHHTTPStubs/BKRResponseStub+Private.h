//
//  BKRResponseStub+Private.h
//  Pods
//
//  Created by Jordan Zucker on 4/14/16.
//
//

#import "BKRResponseStub.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface BKRResponseStub ()


@property (nonatomic, assign, readwrite) NSTimeInterval recordedRequestTime; // time until NSURLResponseFrame
@property (nonatomic, assign, readwrite) NSTimeInterval recordedResponseTime; // time until last piece of data (last BKRDataFrame)

@end

NS_ASSUME_NONNULL_END
