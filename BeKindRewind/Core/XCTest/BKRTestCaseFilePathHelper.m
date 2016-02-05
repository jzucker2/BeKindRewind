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
    return [self dictionaryForPlistFile:plistFileName inBundle:[self _classStringFromTestCase:testCase] inBundleForClass:testCase.class];
}

+ (NSString *)_classStringFromTestCase:(XCTestCase *)testCase {
    return NSStringFromClass(testCase.class);
}

+ (NSBundle *)writingBundleForTestCase:(XCTestCase *)testCase inDirectory:(NSString *)filePath {
    NSParameterAssert(testCase);
    NSString *bundleName = [self _classStringFromTestCase:testCase];
    return [self writingBundleNamed:bundleName inDirectory:filePath];
}

+ (BOOL)writeDictionary:(NSDictionary *)dictionary forTestCase:(XCTestCase *)testCase toDirectory:(NSString *)directoryPath {
    NSBundle *testBundle = [self writingBundleForTestCase:testCase inDirectory:directoryPath];
    NSString *plistName = [NSStringFromSelector(testCase.invocation.selector) stringByAppendingPathExtension:@"plist"];
    NSString *finalFilePath = [testBundle.bundlePath stringByAppendingPathComponent:plistName];
    return [self writeDictionary:dictionary toFile:finalFilePath];
}

@end
