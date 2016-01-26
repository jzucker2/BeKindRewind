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

- (void)testFindExistingBundleInProject {
    NSBundle *bundle = [BKRFilePathHelper findBundle:@"SimpleBundle" containingClass:self.class];
    XCTAssertNotNil(bundle);
    XCTAssertTrue([bundle.bundlePath hasSuffix:@".xctest/SimpleBundle.bundle"]);
}

- (void)testReturnsNilForNonexistentBundleInProject {
    NSBundle *bundle = [BKRFilePathHelper findBundle:@"IDontExist.bundle" containingClass:self.class];
    XCTAssertNil(bundle);
}

- (void)testFindSimpleFileFromExistingBundleInProject {
    NSString *filePath = [BKRFilePathHelper findPathForFile:@"SimpleFileInBundle.txt" inBundle:@"SimpleBundle" inBundleForClass:self.class];
    XCTAssertNotNil(filePath);
    XCTAssertTrue([filePath hasSuffix:@".xctest/SimpleBundle.bundle/SimpleFileInBundle.txt"]);
}

- (void)testReturnNilForNonexistentFileInExistingBundleInProject {
    NSString *filePath = [BKRFilePathHelper findPathForFile:@"IDontExist.txt" inBundle:@"SimpleBundle" inBundleForClass:self.class];
    XCTAssertNil(filePath);
}

- (void)testReturnNilForNonexistentFile {
    NSString *expectedFilePath = [BKRFilePathHelper findPathForFile:@"IDontExist.txt" inBundleForClass:self.class];
    XCTAssertNil(expectedFilePath);
}

- (void)testThrowsExceptionForCreatingDictionaryFromValidNonPlistFile {
    NSString *filePath = [BKRFilePathHelper findPathForFile:@"SimpleFile.txt" inBundleForClass:self.class];
    XCTAssertNotNil(filePath);
    XCTAssertThrowsSpecificNamed([BKRFilePathHelper dictionaryForPlistFilePath:filePath], NSException, NSInternalInconsistencyException);

}

- (void)testThrowsExceptionForCreatingDictionaryFromNilFilePath {
    XCTAssertThrowsSpecificNamed([BKRFilePathHelper dictionaryForPlistFilePath:nil], NSException, NSInternalInconsistencyException);
}

- (void)testReturnsDictionaryForPlistFilePathContainingRootDictionary {
    NSString *filePath = [BKRFilePathHelper findPathForFile:@"SimplePlistDictionary.plist" inBundleForClass:self.class];
    XCTAssertNotNil(filePath);
    NSDictionary *dictionary = [BKRFilePathHelper dictionaryForPlistFilePath:filePath];
    XCTAssertNotNil(dictionary);
    NSDictionary *expectedDictionary = @{
                                         @"foo": @"bar",
                                         @"baz": @"qux"
                                         };
    XCTAssertEqualObjects(dictionary, expectedDictionary);
}

- (void)testThrowsExceptinForCreatingDictionaryFromPlistFilePathContainingRootArray {
    NSString *filePath = [BKRFilePathHelper findPathForFile:@"SimplePlistArray.plist" inBundleForClass:self.class];
    XCTAssertNotNil(filePath);
    XCTAssertThrowsSpecificNamed([BKRFilePathHelper dictionaryForPlistFilePath:filePath], NSException, NSInternalInconsistencyException);
}

- (void)testReturnsDictionaryForPlistInABundle {
    NSDictionary *dictionary = [BKRFilePathHelper dictionaryForPlistFile:@"testReturnsDictionaryFromMatchingPlistForThisTestCase.plist" inBundle:@"BKRTestCaseFilePathHelperTestCase" inBundleForClass:self.class];
    XCTAssertNotNil(dictionary);
    NSDictionary *expectedDictionary = @{
                                         @"foo": @"bar",
                                         @"baz": @"qux"
                                         };
    XCTAssertEqualObjects(dictionary, expectedDictionary);
}

- (void)testThrowsExceptionForExistentPlistInABundleWithRootArray {
    XCTAssertThrowsSpecificNamed([BKRFilePathHelper dictionaryForPlistFile:@"testThrowsExceptionForExistentPlistWithRootArrayMatchingThisTestCase.plist" inBundle:@"BKRTestCaseFilePathHelperTestCase" inBundleForClass:self.class], NSException, NSInternalInconsistencyException);
}

- (void)testThrowsExceptionForCreatingDictionaryFromNonPlistFileInABundle {
    XCTAssertThrowsSpecificNamed([BKRFilePathHelper dictionaryForPlistFile:@"SimpleFileInBundle.txt" inBundle:@"SimpleBundle" inBundleForClass:self.class], NSException, NSInternalInconsistencyException);
}

@end
