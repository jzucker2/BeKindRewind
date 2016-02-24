//
//  BKRTestVCR.m
//  Pods
//
//  Created by Jordan Zucker on 2/7/16.
//
//

#import <XCTest/XCTest.h>
//#import "NSURLSessionTask+BKRAdditions.h"
//#import "NSURLSessionTask+BKRTestAdditions.h"
//#import "BKRPlayheadMatcher.h" // remove this
#import "BKRTestConfiguration.h"
//#import "BKRConfiguration.h"
#import "BKRTestVCR.h"

@interface BKRTestVCR ()
//@property (nonatomic, copy) BKRTestConfiguration *configuration;
@end

@implementation BKRTestVCR
//@synthesize currentTestCase = _currentTestCase;

#pragma mark - BKRTestVCRActions

//- (instancetype)initWithTestCase:(XCTestCase *)testCase {
//    self = [super initWithMatcherClass:[BKRPlayheadMatcher class] andEmptyCassetteSavingOption:NO];
//    if (self) {
//        self.beginRecordingBlock = ^void (NSURLSessionTask *task) {
//            NSString *recordingExpectationString = [NSString stringWithFormat:@"Task: %@", task.globallyUniqueIdentifier];
//            task.recordingExpectation = [testCase expectationWithDescription:recordingExpectationString];
//        };
//        self.endRecordingBlock = ^void (NSURLSessionTask *task) {
//            [task.recordingExpectation fulfill];
//        };
//        _currentTestCase = testCase;
//    }
//    return self;
//}
//
//+ (instancetype)vcrWithTestCase:(XCTestCase *)testCase {
//    return [[self alloc] initWithTestCase:testCase];
//}

- (instancetype)initWithTestConfiguration:(BKRTestConfiguration *)configuration {
    self = [super initWithConfiguration:configuration];
    if (self) {
        // does anything need to happen here?
    }
    return self;
}

+ (instancetype)vcrWithTestConfiguration:(BKRTestConfiguration *)configuration {
    return [[self alloc] initWithTestConfiguration:configuration];
}

+ (instancetype)defaultVCRForTestCase:(XCTestCase *)testCase {
    return [[self alloc] initWithTestConfiguration:[BKRTestConfiguration defaultConfigurationWithTestCase:testCase]];
}

- (BKRTestConfiguration *)currentConfiguration {
    return (BKRTestConfiguration *)[[super currentConfiguration] copy];
}

- (XCTestCase *)currentTestCase {
    return self.currentConfiguration.currentTestCase;
}

- (void)record {
    __block XCTestExpectation *recordExpectation = [self.currentTestCase expectationWithDescription:@"record"];
    [self recordWithCompletionBlock:^(BOOL result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [recordExpectation fulfill];
        });
    }];
}

- (void)pause {
    __block XCTestExpectation *pauseExpectation = [self.currentTestCase expectationWithDescription:@"pause"];
    [self pauseWithCompletionBlock:^(BOOL result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [pauseExpectation fulfill];
        });
    }];
}

- (void)play {
    __block XCTestExpectation *playExpectation = [self.currentTestCase expectationWithDescription:@"play"];
    [self playWithCompletionBlock:^(BOOL result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [playExpectation fulfill];
        });
    }];
}

- (void)stop {
    __block XCTestExpectation *stopExpectation = [self.currentTestCase expectationWithDescription:@"stop"];
    [self stopWithCompletionBlock:^(BOOL result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [stopExpectation fulfill];
        });
    }];
}

- (void)reset {
    __block XCTestExpectation *resetExpectation = [self.currentTestCase expectationWithDescription:@"reset"];
    [self resetWithCompletionBlock:^(BOOL result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [resetExpectation fulfill];
        });
    }];
}

- (BOOL)insert:(BKRVCRCassetteLoadingBlock)cassetteLoadingBlock {
    __block XCTestExpectation *insertExpectation = [self.currentTestCase expectationWithDescription:@"insert"];
    return [self insert:cassetteLoadingBlock completionHandler:^(BOOL result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [insertExpectation fulfill];
        });
    }];
}

- (BOOL)eject:(BKRVCRCassetteSavingBlock)cassetteSavingBlock {
    __block XCTestExpectation *ejectExpectation = [self.currentTestCase expectationWithDescription:@"eject"];
    return [self eject:cassetteSavingBlock completionHandler:^(BOOL result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ejectExpectation fulfill];
        });
    }];
}

@end
