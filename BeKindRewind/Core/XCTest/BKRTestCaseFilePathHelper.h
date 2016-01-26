//
//  BKRTestCaseFilePathHelper.h
//  Pods
//
//  Created by Jordan Zucker on 1/26/16.
//
//

#import "BKRFilePathHelper.h"

@class XCTestCase;
@interface BKRTestCaseFilePathHelper : BKRFilePathHelper

+ (NSDictionary *)dictionaryForTestCase:(XCTestCase *)testCase;

@end
