//
//  BKRTestConfiguration.m
//  Pods
//
//  Created by Jordan Zucker on 2/23/16.
//
//

#import <XCTest/XCTest.h>
#import "BKRTestConfiguration.h"
#import "BKRPlayheadMatcher.h"
#import "NSURLSessionTask+BKRAdditions.h"
#import "NSURLSessionTask+BKRTestAdditions.h"

static NSTimeInterval const kBKRTestConfigurationSetUpTimeoutDefault = 15;
static NSTimeInterval const kBKRTestConfigurationTearDownTimeoutDefault = 15;

@interface BKRTestConfiguration () <NSCopying>
@end

@implementation BKRTestConfiguration

- (instancetype)initWithMatcherClass:(Class<BKRRequestMatching>)matcherClass andTestCase:(XCTestCase *)testCase {
    NSParameterAssert(testCase);
    self = [super initWithMatcherClass:matcherClass];
    if (self) {
        _currentTestCase = testCase;
        _setUpExpectationTimeout = kBKRTestConfigurationSetUpTimeoutDefault;
        _tearDownExpectationTimeout = kBKRTestConfigurationTearDownTimeoutDefault;
    }
    return self;
}

+ (instancetype)defaultConfigurationWithTestCase:(XCTestCase *)testCase {
    BKRTestConfiguration *configuration = [[self alloc] initWithMatcherClass:[BKRPlayheadMatcher class] andTestCase:testCase];
    configuration.beginRecordingBlock = ^void (NSURLSessionTask *task) {
        NSString *recordingExpectationString = [NSString stringWithFormat:@"Task: %@", task.BKR_globallyUniqueIdentifier];
        task.BKR_recordingExpectation = [testCase expectationWithDescription:recordingExpectationString];
    };
    configuration.endRecordingBlock = ^void (NSURLSessionTask *task) {
        [task.BKR_recordingExpectation fulfill];
    };
    return configuration;
}

+ (instancetype)configurationWithMatcherClass:(Class<BKRRequestMatching>)matcherClass andTestCase:(XCTestCase *)testCase {
    return [[self alloc] initWithMatcherClass:matcherClass andTestCase:testCase];
}

- (void)setSetUpExpectationTimeout:(NSTimeInterval)setUpExpectationTimeout {
    NSParameterAssert(setUpExpectationTimeout > 0);
    if (setUpExpectationTimeout <= 0) {
        NSLog(@"The reset expectation must be greater than 0 (instead of %f) or else the wait will not occur.", setUpExpectationTimeout);
        setUpExpectationTimeout = kBKRTestConfigurationSetUpTimeoutDefault;
    }
    _setUpExpectationTimeout = setUpExpectationTimeout;
}

- (void)setTearDownExpectationTimeout:(NSTimeInterval)tearDownExpectationTimeout {
    NSParameterAssert(tearDownExpectationTimeout > 0);
    if (tearDownExpectationTimeout <= 0) {
        NSLog(@"The reset expectation must be greater than 0 (instead of %f) or else the wait will not occur.", tearDownExpectationTimeout);
        tearDownExpectationTimeout = kBKRTestConfigurationTearDownTimeoutDefault;
    }
    _tearDownExpectationTimeout = tearDownExpectationTimeout;
}

- (id)copyWithZone:(NSZone *)zone {
    BKRTestConfiguration *configuration = [[[self class] allocWithZone:zone] init];
    configuration.matcherClass = self.matcherClass;
    configuration.shouldSaveEmptyCassette = self.shouldSaveEmptyCassette;
    configuration.currentTestCase = self.currentTestCase;
    configuration.beginRecordingBlock = self.beginRecordingBlock;
    configuration.endRecordingBlock = self.endRecordingBlock;
    configuration.setUpExpectationTimeout = self.setUpExpectationTimeout;
    configuration.tearDownExpectationTimeout = self.tearDownExpectationTimeout;
    return configuration;
}

@end
