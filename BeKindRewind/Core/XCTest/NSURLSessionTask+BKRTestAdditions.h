//
//  NSURLSessionTask+BKRTestAdditions.h
//  Pods
//
//  Created by Jordan Zucker on 2/3/16.
//
//

#import <Foundation/Foundation.h>

@class XCTestExpectation;
@interface NSURLSessionTask (BKRTestAdditions)

@property (nonatomic, strong) XCTestExpectation *recordingExpectation;

@end
