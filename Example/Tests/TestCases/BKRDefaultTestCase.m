//
//  BKRDefaultTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/26/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRTestCase.h>
#import <BeKindRewind/BKRTestVCR.h>
//#import <BeKindRewind/BKRTestVCRActions.h>
//#import <BeKindRewind/BKRVCRActions.h>
#import <BeKindRewind/BKRCassette.h>
#import <BeKindRewind/BKRTestCaseFilePathHelper.h>
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
    XCTAssertNil(self.currentVCR);
}

- (void)testDefaultConfiguration {
    BKRTestConfiguration *configuration = [self testConfiguration];
    [self assertDefaultTestConfiguration:configuration];
}

- (void)testDefaultIsRecording {
    XCTAssertTrue([self isRecording], @"Default return value for isRecording is YES");
    XCTAssertNotNil(self.currentVCR, @"There must be a VCR object that was created during setUp");
    XCTAssertEqual(self.currentVCR.state, BKRVCRStateRecording, @"Current VCR should be in recording state");
}

- (void)testDefaultVCR {
    XCTAssertNotNil(self.currentVCR);
    [self assertDefaultTestConfiguration:self.currentVCR.currentConfiguration];
}

- (void)testDefaultBaseFixturesDirectoryFilePath {
    XCTAssertEqualObjects([self baseFixturesDirectoryFilePath], [BKRTestCaseFilePathHelper documentsDirectory]);
}

- (void)testDefaultRecordingCassette {
    // Should be a blank cassette
    XCTAssertNotNil(self.currentVCR.currentCassette);
    XCTAssertEqual(self.currentVCR.currentCassette.allScenes.count, 0);
}

- (void)testDefaultRecordingCassetteFilePathWithBaseDirectoryFilePath {
    NSString *baseFixturesDirectory = [self baseFixturesDirectoryFilePath];
    XCTAssertNotNil(baseFixturesDirectory);
    NSString *recordingCassettePath = [self recordingCassetteFilePathWithBaseDirectoryFilePath:baseFixturesDirectory];
    XCTAssertNotNil(recordingCassettePath);
    XCTAssertEqualObjects(recordingCassettePath, [BKRTestCaseFilePathHelper writingFinalPathForTestCase:self inTestSuiteBundleInDirectory:baseFixturesDirectory]);
}

- (void)testDefaultPlayingCassette {
    // Fixture exists for this test
    BKRCassette *playingCassette = [self playingCassette];
    XCTAssertNotNil(playingCassette);
    XCTAssertEqual(playingCassette.allScenes.count, 1);
    XCTAssertNotNil(playingCassette.creationDate);
}

@end
