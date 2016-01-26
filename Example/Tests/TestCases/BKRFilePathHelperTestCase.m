//
//  BKRFilePathHelperTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/26/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRFilePathHelper.h>
#import <XCTest/XCTest.h>
#import "XCTestCase+BKRAdditions.h"

@interface BKRFilePathHelperTestCase : XCTestCase

@end

@implementation BKRFilePathHelperTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFindSimpleFile {
    NSString *expectedFilePath = [BKRFilePathHelper findPathForFile:@"SimpleFile.txt" inBundleForClass:self.class];
    XCTAssertNotNil(expectedFilePath);
    // start of file path is dependent on machine, that will change depending on where it is run.
    // but end will always be the same
    XCTAssertTrue([expectedFilePath hasSuffix:@".xctest/SimpleFile.txt"]);
}

- (void)testReturnNilForNonexistentFile {
    NSString *expectedFilePath = [BKRFilePathHelper findPathForFile:@"IDontExist.txt" inBundleForClass:self.class];
    XCTAssertNil(expectedFilePath);
}

- (void)testThrowsExceptionForCreatingDictionaryFromValidNonPlistFile {
    XCTAssertThrowsSpecificNamed([BKRFilePathHelper dictionaryForPlistFile:@"SimpleFile.txt" inBundleForClass:self.class], NSException, NSInternalInconsistencyException);
}

- (void)testThrowsExceptionForCreatingDictionaryFromNonExistentPlistFile {
//    NSDictionary *dictionary = [BKRFilePathHelper dictionaryForPlistFile:@"IDontExist.plist" inBundleForClass:self.class];
//    XCTAssertNil(dictionary);
    XCTAssertThrowsSpecificNamed([BKRFilePathHelper dictionaryForPlistFile:@"IDontExist.plist" inBundleForClass:self.class], NSException, NSInternalInconsistencyException);
}

- (void)testThrowsExceptionForCreatingDictionaryFromNonExistentNonPlistFile {
    XCTAssertThrowsSpecificNamed([BKRFilePathHelper dictionaryForPlistFile:@"IDontExist.txt" inBundleForClass:self.class], NSException, NSInternalInconsistencyException);
//    NSDictionary *dictionary = [BKRFilePathHelper dictionaryForPlistFile:@"IDontExist.txt" inBundleForClass:self.class];
//    XCTAssertNil(dictionary);
}

- (void)testReturnsDictionaryForPlistFilePathContainingRootDictionary {
    NSDictionary *dictionary = [BKRFilePathHelper dictionaryForPlistFile:@"SimplePlistDictionary.plist" inBundleForClass:self.class];
    XCTAssertNotNil(dictionary);
    NSDictionary *expectedDictionary = @{
                                         @"foo": @"bar",
                                         @"baz": @"qux"
                                         };
    XCTAssertEqualObjects(dictionary, expectedDictionary);
}

- (void)testThrowsExceptinForCreatingDictionaryFromPlistFilePathContainingRootArray {
    XCTAssertThrowsSpecificNamed([BKRFilePathHelper dictionaryForPlistFile:@"SimplePlistArray.plist" inBundleForClass:self.class], NSException, NSInternalInconsistencyException);
}

@end
