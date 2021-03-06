//
//  NSURLSessionTask+BKRTestAdditions.m
//  Pods
//
//  Created by Jordan Zucker on 2/3/16.
//
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "NSURLSessionTask+BKRTestAdditions.h"

static const void *BKRTaskTestExpectationKey = &BKRTaskTestExpectationKey;

@implementation NSURLSessionTask (BKRTestAdditions)
@dynamic BKR_recordingExpectation;

- (void)setBKR_recordingExpectation:(XCTestExpectation *)recordingExpectation {
    objc_setAssociatedObject(self, BKRTaskTestExpectationKey, recordingExpectation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (XCTestExpectation *)BKR_recordingExpectation {
    return objc_getAssociatedObject(self, BKRTaskTestExpectationKey);
}

@end
