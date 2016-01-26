//
//  BKRFrame.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRPlistSerializing.h"

// Abstract for a recordable element of a network call (response, data, request, etc...)

@interface BKRFrame : NSObject <BKRPlistSerializing>

- (instancetype)initWithTask:(NSURLSessionTask *)task;
+ (instancetype)frameWithTask:(NSURLSessionTask *)task;

- (instancetype)initFromFrame:(BKRFrame *)frame;
+ (instancetype)frameFromFrame:(BKRFrame *)frame;

- (instancetype)initWithIdentifier:(NSString *)identifier;
+ (instancetype)frameWithIdentifier:(NSString *)identifier;

@property (nonatomic, copy, readonly) NSString *uniqueIdentifier;
@property (nonatomic, readonly) NSDate *creationDate;

@end
