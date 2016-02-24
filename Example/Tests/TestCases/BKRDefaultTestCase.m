//
//  BKRDefaultTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/26/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRTestCase.h>
#import <BeKindRewind/BKRTestVCR.h>
#import <BeKindRewind/BKRTestVCRActions.h>
#import <BeKindRewind/BKRTestConfiguration.h>
#import "BKRBaseTestCase.h"
#import "XCTestCase+BKRHelpers.h"

@interface BKRDefaultTestCase : BKRTestCase
@end

@implementation BKRDefaultTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDefaultConfiguration {
    BKRTestConfiguration *configuration = [self testConfiguration];
    [self assertDefaultTestConfiguration:configuration];
}

- (void)testDefaultIsRecording {
    XCTAssertTrue([self isRecording], @"Default return value for isRecording is YES");
    XCTAssertEqual(self.currentVCR.state, BKRVCRStateRecording, @"Current VCR should be in recording state");
}

- (void)testDefaultVCR {
    XCTAssertNotNil(self.currentVCR);
    [self assertDefaultTestConfiguration:self.currentVCR.currentConfiguration];
}

@end
