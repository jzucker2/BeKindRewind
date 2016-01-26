//
//  BKRTestCaseFilePathHelper.m
//  Pods
//
//  Created by Jordan Zucker on 1/26/16.
//
//

#import <XCTest/XCTest.h>
#import "BKRTestCaseFilePathHelper.h"

@implementation BKRTestCaseFilePathHelper

+ (NSDictionary *)dictionaryForTestCase:(XCTestCase *)testCase {
    NSString *plistFileName = [NSString stringWithFormat:@"%@.plist", NSStringFromSelector(testCase.invocation.selector)];
    return [self dictionaryForPlistFile:plistFileName inBundle:NSStringFromClass(testCase.class) inBundleForClass:testCase.class];
}

@end
