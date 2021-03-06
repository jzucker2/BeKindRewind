//
//  BKRTestCase.m
//  Pods
//
//  Created by Jordan Zucker on 1/26/16.
//
//

#import "BKRCassette.h"
#import "BKRCassette+Playable.h"
#import "BKRTestVCR.h"
#import "BKRTestVCRActions.h"
#import "BKRTestCase.h"
#import "BKRTestConfiguration.h"
#import "BKRTestCaseFilePathHelper.h"

@interface BKRTestCase ()
@property (nonatomic, strong, readwrite) id<BKRTestVCRActions> currentVCR;
@end

@implementation BKRTestCase

- (BOOL)isRecording {
    return YES;
}

- (BKRTestConfiguration *)testConfiguration {
    return [BKRTestConfiguration defaultConfigurationWithTestCase:self];
}

- (id<BKRTestVCRActions>)testVCRWithConfiguration:(BKRTestConfiguration *)configuration {
    return [BKRTestVCR vcrWithTestConfiguration:configuration];
}

- (NSString *)baseFixturesDirectoryFilePath {
    return [BKRTestCaseFilePathHelper documentsDirectory];
}

- (NSString *)recordingCassetteFilePathWithBaseDirectoryFilePath:(NSString *)baseDirectoryFilePath {
    NSParameterAssert(baseDirectoryFilePath);
    return [BKRTestCaseFilePathHelper writingFinalPathForTestCase:self inTestSuiteBundleInDirectory:baseDirectoryFilePath];
}

- (BKRCassette *)playingCassette {
    NSDictionary *cassetteDictionary = [BKRTestCaseFilePathHelper dictionaryForTestCase:self];
    XCTAssertNotNil(cassetteDictionary); // is this necessary? maybe this is overkill and bad for devs
    return [BKRCassette cassetteFromDictionary:cassetteDictionary];
}

- (BKRCassette *)recordingCassette {
    return [BKRCassette cassette];
}

- (void)setUp {
    [super setUp];
    self.currentVCR = [self testVCRWithConfiguration:[self testConfiguration]];
    BKRVCRState assertionState = BKRVCRStateStopped;
    XCTAssertEqual(self.currentVCR.state, assertionState, @"currentVCR should begin in stopped state");
    BKRWeakify(self);
    if ([self isRecording]) {
        XCTAssertTrue([self.currentVCR insert:^BKRCassette *{
            BKRStrongify(self);
            return [self recordingCassette];
        }]);
        [self.currentVCR record];
        assertionState = BKRVCRStateRecording;
    } else {
        XCTAssertTrue([self.currentVCR insert:^BKRCassette *{
            BKRStrongify(self);
            return [self playingCassette];
        }]);
        [self.currentVCR play];
        assertionState = BKRVCRStatePlaying;
    }
    NSTimeInterval setUpExpectationTimeout = [[self.currentVCR currentConfiguration] setUpExpectationTimeout];
    [self waitForExpectationsWithTimeout:setUpExpectationTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    XCTAssertEqual(self.currentVCR.state, assertionState);
}

- (void)tearDown {
    if ([self isRecording]) {
        BKRWeakify(self);
        [self.currentVCR eject:^NSString *(BKRCassette *cassette) {
            BKRStrongify(self);
            return [self recordingCassetteFilePathWithBaseDirectoryFilePath:[self baseFixturesDirectoryFilePath]];
        }];
    }
    [self.currentVCR reset]; // reset for BKRRecorder mostly
    NSTimeInterval tearDownExpectationTimeout = [[self.currentVCR currentConfiguration] tearDownExpectationTimeout];
    [self waitForExpectationsWithTimeout:tearDownExpectationTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    self.currentVCR = nil; // clear the VCR so that it can't possibly carry over to the next test
    [super tearDown];
}

@end
