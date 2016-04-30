//
//  BKRPlayheadMatcherTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 2/25/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BeKindRewind.h>
#import "XCTestCase+BKRHelpers.h"

@interface BKRPlayheadWithOverridesMatcher : BKRPlayheadMatcher
@end

@implementation BKRPlayheadWithOverridesMatcher

- (BOOL)hasMatchForURLComponent:(NSString *)URLComponent withRequestComponentValue:(id)requestComponentValue possibleMatchComponentValue:(id)possibleMatchComponentValue {
    if ([URLComponent isEqualToString:@"scheme"]) {
        if ([requestComponentValue isEqualToString:@"bkr"]) {
            return YES;
        }
    } else if ([URLComponent isEqualToString:@"path"]) {
        if (
            [requestComponentValue isEqualToString:@"bar"] &&
            [possibleMatchComponentValue isEqualToString:@"foo"]
            ) {
            return YES;
        }
    }
    return YES;
}

@end

@interface BKRPlayheadWithPathOverrideMatcher : BKRPlayheadWithOverridesMatcher
@end

@implementation BKRPlayheadWithPathOverrideMatcher

- (NSDictionary *)requestComparisonOptions {
    NSMutableDictionary *superOptions = [super requestComparisonOptions].mutableCopy;
    superOptions[kBKROverrideNSURLComponentsPropertiesOptionsKey] = @[@"path"];
    return superOptions.copy;
}

@end

@interface BKRPlayheadWithSchemeOverrideMatcher : BKRPlayheadWithOverridesMatcher
@end

@implementation BKRPlayheadWithSchemeOverrideMatcher

- (NSDictionary *)requestComparisonOptions {
    NSMutableDictionary *superOptions = [super requestComparisonOptions].mutableCopy;
    superOptions[kBKROverrideNSURLComponentsPropertiesOptionsKey] = @[@"scheme"];
    return superOptions.copy;
}

@end

@interface BKRPlayheadWithPathAndSchemeOverrideMatcher : BKRPlayheadWithOverridesMatcher
@end

@implementation BKRPlayheadWithPathAndSchemeOverrideMatcher

- (NSDictionary *)requestComparisonOptions {
    NSMutableDictionary *superOptions = [super requestComparisonOptions].mutableCopy;
    superOptions[kBKROverrideNSURLComponentsPropertiesOptionsKey] = @[@"path", @"scheme"];
    return superOptions.copy;
}

@end

@interface BKRPlayheadMatcherTestCase : BKRTestCase
@end

@implementation BKRPlayheadMatcherTestCase

- (BOOL)isRecording {
    return NO;
}

- (BKRTestConfiguration *)testConfiguration {
    BKRTestConfiguration *superConfiguration = [super testConfiguration];
    if (self.invocation.selector == @selector(testOverrideMatcher)) {
        superConfiguration.matcherClass = [BKRPlayheadWithSchemeOverrideMatcher class];
    }
    return superConfiguration;
}

- (void)testOverrideMatcher {
    BKRTestExpectedResult *getResult = [self HTTPBinGetRequestWithQueryString:@"test=test" withRecording:NO];
    getResult.URLString = @"bkr://httpbin.org/get?test=test";
    [self BKRTest_executeHTTPBinNetworkCallsForExpectedResults:@[getResult] simultaneously:NO withTaskCompletionAssertions:nil taskTimeoutHandler:nil];
}

//TODO: add more tests

@end
