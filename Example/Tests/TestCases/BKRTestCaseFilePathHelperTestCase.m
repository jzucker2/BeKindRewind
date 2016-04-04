//
//  BKRTestCaseFilePathHelperTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/26/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <BeKindRewind/BKRTestCaseFilePathHelper.h>
#import "XCTestCase+BKRFilePathHelpers.h"

@interface BKRTestCaseFilePathHelperTestCase : XCTestCase

@end

@implementation BKRTestCaseFilePathHelperTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testReturnsDictionaryFromMatchingPlistForThisTestCase {
    NSDictionary *dictionary = [BKRTestCaseFilePathHelper dictionaryForTestCase:self];
    XCTAssertNotNil(dictionary);
    NSDictionary *expectedDictionary = @{
                                         @"foo": @"bar",
                                         @"baz": @"qux"
                                         };
    XCTAssertEqualObjects(dictionary, expectedDictionary);
}

- (void)testCreateBundleForThisTestInDocumentsDirectory {
    NSString *documentsDirectory = [BKRFilePathHelper documentsDirectory];
    XCTAssertNotNil(documentsDirectory);
    NSBundle *createBundle = [BKRTestCaseFilePathHelper writingBundleForTestCase:self inDirectory:documentsDirectory];
    XCTAssertNotNil(createBundle);
    XCTAssertTrue([createBundle.bundlePath hasSuffix:[self expectedSuffixForBundleNamedAfterTestCaseInDocumentsDirectory:self]]);
}

- (void)testReturnsExistingBundleForWritingIfAlreadyExists {
    NSString *documentsDirectory = [BKRFilePathHelper documentsDirectory];
    XCTAssertNotNil(documentsDirectory);
    NSBundle *createdBundle = [BKRFilePathHelper writingBundleNamed:NSStringFromClass(self.class) inDirectory:documentsDirectory];
    XCTAssertNotNil(createdBundle);
    XCTAssertTrue([createdBundle.bundlePath hasSuffix:[self expectedSuffixForBundleNamedAfterTestCaseInDocumentsDirectory:self]]);
    
    NSString *createdFileName = @"createdfile.txt";
    NSString *createdFilePath = [createdBundle.bundlePath stringByAppendingPathComponent:createdFileName];
    NSData *createdFileContents = [[NSUUID UUID].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertNotNil(createdFileContents);
    BOOL fileCreated = [[NSFileManager defaultManager] createFileAtPath:createdFilePath contents:createdFileContents attributes:nil];
    XCTAssertTrue(fileCreated);
    
    NSBundle *sameBundle = [BKRTestCaseFilePathHelper writingBundleForTestCase:self inDirectory:documentsDirectory];
    XCTAssertNotNil(sameBundle);
    NSString *otherCreatedFilePath = [sameBundle.bundlePath stringByAppendingPathComponent:createdFileName];
    XCTAssertNotNil(otherCreatedFilePath);
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:otherCreatedFilePath];
    XCTAssertTrue(fileExists);
    NSData *sameFileContents = [NSData dataWithContentsOfFile:otherCreatedFilePath];
    XCTAssertEqualObjects(createdFileContents, sameFileContents);
    
    XCTAssertEqualObjects(createdBundle, sameBundle);
}

- (void)testWriteDictionaryToPlistAtTestCaseFilePath {
    NSString *expectedBundleName = [NSStringFromClass(self.class) stringByAppendingPathExtension:@"bundle"];
    XCTAssertNotNil(expectedBundleName);
    
    NSDictionary *testDictionary = @{
                                     @"foo": @"bar"
                                     };
    
    NSString *documentsDirectory = [BKRFilePathHelper documentsDirectory];
    XCTAssertNotNil(documentsDirectory);
    XCTAssertTrue([documentsDirectory hasSuffix:self.documentsDirectorySuffix]);
    
    BOOL plistCreated = [BKRTestCaseFilePathHelper writeDictionary:testDictionary forTestCase:self toDirectory:documentsDirectory];
    XCTAssertTrue(plistCreated);
    
    NSString *expectedPlistName = [NSStringFromSelector(self.invocation.selector) stringByAppendingPathExtension:@"plist"];
    NSString *expectedPlistInBundleSubPath = [expectedBundleName stringByAppendingPathComponent:expectedPlistName];
    XCTAssertNotNil(expectedPlistInBundleSubPath);
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:expectedPlistInBundleSubPath];
    XCTAssertNotNil(fullPath);
    
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:fullPath];
    XCTAssertTrue(exists);
    
    NSDictionary *expectedDictionary = [NSDictionary dictionaryWithContentsOfFile:fullPath];
    XCTAssertNotNil(expectedDictionary);
    XCTAssertEqualObjects(testDictionary, expectedDictionary);
}

- (void)testOverwriteExistingDictionaryToPlistAtTestCaseFilePath {
    NSString *expectedBundleName = [NSStringFromClass(self.class) stringByAppendingPathExtension:@"bundle"];
    XCTAssertNotNil(expectedBundleName);
    
    NSDictionary *originalDictionary = @{
                                     @"foo": @"bar"
                                     };
    
    NSString *documentsDirectory = [BKRFilePathHelper documentsDirectory];
    XCTAssertNotNil(documentsDirectory);
    XCTAssertTrue([documentsDirectory hasSuffix:self.documentsDirectorySuffix]);
    
    BOOL plistCreated = [BKRTestCaseFilePathHelper writeDictionary:originalDictionary forTestCase:self toDirectory:documentsDirectory];
    XCTAssertTrue(plistCreated);
    
    NSString *expectedPlistName = [NSStringFromSelector(self.invocation.selector) stringByAppendingPathExtension:@"plist"];
    NSString *expectedPlistInBundleSubPath = [expectedBundleName stringByAppendingPathComponent:expectedPlistName];
    XCTAssertNotNil(expectedPlistInBundleSubPath);
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:expectedPlistInBundleSubPath];
    XCTAssertNotNil(fullPath);
    
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:fullPath];
    XCTAssertTrue(exists);
    
    NSDictionary *expectedDictionary = [NSDictionary dictionaryWithContentsOfFile:fullPath];
    XCTAssertNotNil(expectedDictionary);
    XCTAssertEqualObjects(originalDictionary, expectedDictionary);
    
    NSDictionary *newDictionary = @{
                                    @"baz": @"qux"
                                    };
    BOOL overwotePlist = [BKRTestCaseFilePathHelper writeDictionary:newDictionary forTestCase:self toDirectory:documentsDirectory];
    XCTAssertTrue(overwotePlist);
    
    BOOL stillExists = [[NSFileManager defaultManager] fileExistsAtPath:fullPath];
    XCTAssertTrue(stillExists);
    
    NSDictionary *newExpectedDictionary = [NSDictionary dictionaryWithContentsOfFile:fullPath];
    XCTAssertNotNil(newExpectedDictionary);
    XCTAssertNotEqualObjects(originalDictionary, newExpectedDictionary);
    XCTAssertEqualObjects(newDictionary, newExpectedDictionary);
}

#if DEBUG

- (void)testThrowsExceptionForExistentPlistWithRootArrayMatchingThisTestCase {
    XCTAssertThrowsSpecificNamed([BKRTestCaseFilePathHelper dictionaryForTestCase:self], NSException, NSInternalInconsistencyException);
}

- (void)testThrowsExceptionForReturningDictionaryFromNonexistentPlist {
    XCTAssertThrowsSpecificNamed([BKRTestCaseFilePathHelper dictionaryForTestCase:self], NSException, NSInternalInconsistencyException);
}

#endif

@end
