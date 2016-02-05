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

// finds fixture from app target (must be included in target using Xcode)
+ (NSDictionary *)dictionaryForTestCase:(XCTestCase *)testCase;

// creates bundle if it does not exist at directory location
+ (NSBundle *)writingBundleForTestCase:(XCTestCase *)testCase inDirectory:(NSString *)filePath;

// directory path should already exist
+ (BOOL)writeDictionary:(NSDictionary *)dictionary forTestCase:(XCTestCase *)testCase toDirectory:(NSString *)directoryPath;

@end
