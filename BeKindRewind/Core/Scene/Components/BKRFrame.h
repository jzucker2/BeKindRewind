//
//  BKRFrame.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRSerializer.h"

// Abstract for a recordable element of a network call (response, data, request, etc...)

@interface BKRFrame : NSObject <BKRSerializer>

- (instancetype)initWithTask:(NSURLSessionTask *)task;
+ (instancetype)frameWithTask:(NSURLSessionTask *)task;

- (instancetype)initWithFrame:(BKRFrame *)frame;
//+ (instancetype)frameWithFrame:(BKRFrame *)frame;

@property (nonatomic, copy, readonly) NSString *uniqueIdentifier;
@property (nonatomic, readonly) NSDate *creationDate;

@end
