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

@interface BKRTestConfiguration () <NSCopying>

@end

@implementation BKRTestConfiguration

- (instancetype)initWithMatcherClass:(Class<BKRRequestMatching>)matcherClass andTestCase:(XCTestCase *)testCase {
    NSParameterAssert(testCase);
    self = [super initWithMatcherClass:matcherClass];
    if (self) {
        _currentTestCase = testCase;
    }
    return self;
}

+ (instancetype)defaultConfigurationWithTestCase:(XCTestCase *)testCase {
    BKRTestConfiguration *configuration = [[self alloc] initWithMatcherClass:[BKRPlayheadMatcher class] andTestCase:testCase];
    configuration.beginRecordingBlock = ^void (NSURLSessionTask *task) {
        NSString *recordingExpectationString = [NSString stringWithFormat:@"Task: %@", task.globallyUniqueIdentifier];
        task.recordingExpectation = [testCase expectationWithDescription:recordingExpectationString];
    };
    configuration.endRecordingBlock = ^void (NSURLSessionTask *task) {
        [task.recordingExpectation fulfill];
    };
    return configuration;
}

+ (instancetype)configurationWithMatcherClass:(Class<BKRRequestMatching>)matcherClass andTestCase:(XCTestCase *)testCase {
    return [[self alloc] initWithMatcherClass:matcherClass andTestCase:testCase];
}

- (id)copyWithZone:(NSZone *)zone {
    BKRTestConfiguration *configuration = [[[self class] allocWithZone:zone] init];
    configuration.matcherClass = self.matcherClass;
    configuration.shouldSaveEmptyCassette = self.shouldSaveEmptyCassette;
    configuration.currentTestCase = self.currentTestCase;
    configuration.beginRecordingBlock = self.beginRecordingBlock;
    configuration.endRecordingBlock = self.endRecordingBlock;
    return configuration;
}

@end
