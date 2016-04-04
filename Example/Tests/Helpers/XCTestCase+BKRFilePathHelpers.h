//
//  XCTestCase+BKRFilePathHelpers.h
//  BeKindRewind
//
//  Created by Jordan Zucker on 4/1/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface XCTestCase (BKRFilePathHelpers)

- (NSString *)documentsDirectorySuffix;

- (NSString *)expectedSuffixForFileNameInProject:(NSString *)fileName;

/**
 *  Don't include .bundle, it will be added by this method
 *
 *  @param bundleName name of bundle with .bundle extension
 *
 *  @return full expected suffix with .bundle added to file path
 */
- (NSString *)expectedSuffixForBundleInProject:(NSString *)bundleName;

// don't include .bundle in bundleName
- (NSString *)expectedSuffixForFileName:(NSString *)fileName inBundle:(NSString *)bundleName;

// don't include .bundle in bundleName
- (NSString *)expectedSuffixForBundleInDocumentsDirectory:(NSString *)bundleName;

- (NSString *)expectedSuffixForBundleNamedAfterTestCaseInDocumentsDirectory:(XCTestCase *)testCase;

@end
