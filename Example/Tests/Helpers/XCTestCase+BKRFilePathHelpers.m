//
//  XCTestCase+BKRFilePathHelpers.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 4/1/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#if TARGET_OS_IPHONE
    #import <UIKit/UIKit.h>
#endif

#import "XCTestCase+BKRFilePathHelpers.h"

@implementation XCTestCase (BKRFilePathHelpers)

- (NSString *)documentsDirectorySuffix {
#if TARGET_OS_IPHONE
    return @"/data/Documents";
#else
    return @"/Documents";
#endif
}

- (NSString *)expectedSuffixForFileNameInProject:(NSString *)fileName {
    XCTAssertNotNil(fileName);
    NSString *filePathStartingSuffix = nil;
#if TARGET_OS_IPHONE
    filePathStartingSuffix = @".xctest/";
#else
    filePathStartingSuffix = @".xctest/Contents/Resources/";
#endif
    NSString *fullFilePathSuffix = [filePathStartingSuffix stringByAppendingPathComponent:fileName];
    XCTAssertNotNil(fullFilePathSuffix);
    return fullFilePathSuffix;
}

- (NSString *)expectedSuffixForBundleInProject:(NSString *)bundleName {
    XCTAssertNotNil(bundleName);
    XCTAssertFalse([bundleName.pathExtension isEqualToString:@".bundle"], @"Don't include .bundle in bundleName");
    return [self expectedSuffixForFileNameInProject:[bundleName stringByAppendingPathExtension:@"bundle"]];
}

- (NSString *)expectedSuffixForFileName:(NSString *)fileName inBundle:(NSString *)bundleName {
    NSString *expectedBundleSuffix = [self expectedSuffixForBundleInProject:bundleName];
    return [expectedBundleSuffix stringByAppendingPathComponent:fileName];
}

- (NSString *)expectedSuffixForBundleInDocumentsDirectory:(NSString *)bundleName {
    XCTAssertNotNil(bundleName);
    XCTAssertFalse([bundleName.pathExtension isEqualToString:@".bundle"], @"Don't include .bundle in bundleName");
    NSString *bundleNameWithPathExtension = [bundleName stringByAppendingPathExtension:@"bundle"];
    XCTAssertNotNil(bundleNameWithPathExtension);
    return [self.documentsDirectorySuffix stringByAppendingPathComponent:bundleNameWithPathExtension];
    
}

- (NSString *)expectedSuffixForBundleNamedAfterTestCaseInDocumentsDirectory:(XCTestCase *)testCase {
    XCTAssertNotNil(testCase);
    return [self expectedSuffixForBundleInDocumentsDirectory:NSStringFromClass(self.class)];
}

@end
