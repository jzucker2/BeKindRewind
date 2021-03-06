//
//  NSURLSessionTask+BKRTestAdditions.h
//  Pods
//
//  Created by Jordan Zucker on 2/3/16.
//
//

#import <Foundation/Foundation.h>

@class XCTestExpectation;

/**
 *  This category is used in testing for associating the recording
 *  of tasks with an expectation.
 *
 *  @since 1.0.0
 */
@interface NSURLSessionTask (BKRTestAdditions)

/**
 *  This is an added property so that a recording network task can
 *  maintain a reference to the test expectation that ensures it
 *  is fully recorded.
 *
 *  @since 1.0.0
 */
@property (nonatomic, strong) XCTestExpectation *BKR_recordingExpectation;

@end
