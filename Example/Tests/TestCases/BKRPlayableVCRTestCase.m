//
//  BKRPlayableVCRTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 2/11/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRPlayableVCR.h>
#import <BeKindRewind/BKRFilePathHelper.h>
#import <BeKindRewind/BKRPlayheadMatcher.h>
#import "BKRBaseTestCase.h"
#import "XCTestCase+BKRAdditions.h"

@interface BKRPlayableVCRTestCase : BKRBaseTestCase
@property (nonatomic, copy) NSString *testRecordingFilePath;
@property (nonatomic, strong) BKRPlayableVCR *vcr;
@end

@implementation BKRPlayableVCRTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.testRecordingFilePath = [BKRFilePathHelper findPathForFile:@"SimplePlistDictionary.plist" inBundleForClass:self.class];
    XCTAssertNotNil(self.testRecordingFilePath);
    XCTAssertTrue([BKRFilePathHelper filePathExists:self.testRecordingFilePath]);
    
    NSDictionary *cassetteDictionary = [BKRFilePathHelper dictionaryForPlistFilePath:self.testRecordingFilePath];
    XCTAssertNotNil(cassetteDictionary);
    
    self.vcr = [BKRPlayableVCR vcrWithMatcherClass:[BKRPlayheadMatcher class]];
    XCTAssertNotNil(self.vcr);
    __block XCTestExpectation *stubsExpectation;
    self.vcr.beforeAddingStubsBlock = ^void(void) {
        stubsExpectation = [self expectationWithDescription:@"setting up stubs"];
    };
    self.vcr.afterAddingStubsBlock = ^void(void) {
        [stubsExpectation fulfill];
    };
    
    __block XCTestExpectation *insertExpectation = [self expectationWithDescription:@"insert expectation"];
    NSLog(@"insert expectation create");
    XCTAssertTrue([self.vcr insert:self.testRecordingFilePath completionHandler:^(BOOL result, NSString *filePath) {
        NSLog(@"insert expectation fulfill");
        [insertExpectation fulfill];
    }]);
    NSLog(@"insert wait");
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        NSLog(@"insert expire");
        XCTAssertNil(error);
    }];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self.vcr reset];
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
