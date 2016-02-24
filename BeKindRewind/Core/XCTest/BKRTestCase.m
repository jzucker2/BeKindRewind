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
@property (nonatomic, strong, readwrite) id<BKRTestVCRActions>vcr;
@end

@implementation BKRTestCase

- (BOOL)isRecording {
    return YES;
}

- (BKRTestConfiguration *)configuration {
    return [BKRTestConfiguration defaultConfigurationWithTestCase:self];
}

- (instancetype)initWithInvocation:(NSInvocation *)invocation {
    self = [super initWithInvocation:invocation];
    if (self) {
        BKRTestConfiguration *testConfiguration = [[self configuration] copy];
        _vcr = [BKRTestVCR vcrWithTestConfiguration:testConfiguration];
    }
    return self;
}

- (NSString *)recordingCassetteFilePath {
    NSString *baseDirectory = [BKRTestCaseFilePathHelper documentsDirectory];
    XCTAssertNotNil(baseDirectory);
    return [BKRTestCaseFilePathHelper writingFinalPathForTestCase:self inTestSuiteBundleInDirectory:baseDirectory];
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
    BKRVCRState assertionState = BKRVCRStateUnknown;
    BKRWeakify(self);
    if ([self isRecording]) {
        XCTAssertTrue([self.vcr insert:^BKRCassette *{
            BKRStrongify(self);
            return [self recordingCassette];
        }]);
        [self.vcr record];
        assertionState = BKRVCRStateRecording;
    } else {
        XCTAssertTrue([self.vcr insert:^BKRCassette *{
            BKRStrongify(self);
            return [self playingCassette];
        }]);
        [self.vcr play];
        assertionState = BKRVCRStatePlaying;
    }
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    XCTAssertEqual(self.vcr.state, assertionState);
}

- (void)tearDown {
    if ([self isRecording]) {
        BKRWeakify(self);
        [self.vcr eject:^NSString *(BKRCassette *cassette) {
            BKRStrongify(self);
            return [self recordingCassetteFilePath];
        }];
    }
    [self.vcr reset];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    self.vcr = nil; // clear the VCR so that it can't possibly carry over to the next test
    [super tearDown];
}

@end
