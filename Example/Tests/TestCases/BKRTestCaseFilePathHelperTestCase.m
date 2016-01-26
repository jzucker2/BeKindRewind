//
//  BKRTestCaseFilePathHelperTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/26/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRTestCaseFilePathHelper.h>
#import <XCTest/XCTest.h>
#import "XCTestCase+BKRAdditions.h"

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

- (void)testThrowsExceptionForExistentPlistWithRootArrayMatchingThisTestCase {
    XCTAssertThrowsSpecificNamed([BKRTestCaseFilePathHelper dictionaryForTestCase:self], NSException, NSInternalInconsistencyException);
}

- (void)testThrowsExceptionForReturningDictionaryFromNonexistentPlist {
    XCTAssertThrowsSpecificNamed([BKRTestCaseFilePathHelper dictionaryForTestCase:self], NSException, NSInternalInconsistencyException);
}

@end
