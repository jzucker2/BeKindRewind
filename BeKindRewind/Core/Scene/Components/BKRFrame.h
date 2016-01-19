//
//  BKRFrame.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <Foundation/Foundation.h>

// Abstract for a recordable element of a network call (response, data, request, etc...)

@interface BKRFrame : NSObject

- (instancetype)initWithTask:(NSURLSessionTask *)task;
+ (instancetype)frameWithTask:(NSURLSessionTask *)task;

@property (nonatomic, copy, readonly) NSString *uniqueIdentifier;

@end
