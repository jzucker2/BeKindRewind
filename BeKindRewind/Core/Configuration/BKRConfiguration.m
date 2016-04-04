//
//  BKRConfiguration.m
//  Pods
//
//  Created by Jordan Zucker on 2/23/16.
//
//

#import "BKRConfiguration.h"
#import "BKRPlayheadMatcher.h"

static BOOL const kBKRShouldSaveEmptyCassetteDefault = YES;

@interface BKRConfiguration () <NSCopying>
@end

@implementation BKRConfiguration
@synthesize beginRecordingBlock = _beginRecordingBlock;
@synthesize endRecordingBlock = _endRecordingBlock;

- (instancetype)init {
    self = [super init];
    if (self) {
        _shouldSaveEmptyCassette = kBKRShouldSaveEmptyCassetteDefault;
    }
    return self;
}

- (instancetype)initWithMatcherClass:(Class<BKRRequestMatching>)matcherClass {
    NSParameterAssert(matcherClass);
    self = [self init];
    if (self) {
        _matcherClass = matcherClass;
    }
    return self;
}

+ (instancetype)defaultConfiguration {
    return [[self alloc] initWithMatcherClass:[BKRPlayheadMatcher class]];
}

+ (instancetype)configurationWithMatcherClass:(Class<BKRRequestMatching>)matcherClass {
    return [[self alloc] initWithMatcherClass:matcherClass];
}

- (id)copyWithZone:(NSZone *)zone {
    BKRConfiguration *configuration = [[[self class] allocWithZone:zone] init];
    configuration.matcherClass = self.matcherClass;
    configuration.shouldSaveEmptyCassette = self.shouldSaveEmptyCassette;
    configuration.beginRecordingBlock = self.beginRecordingBlock;
    configuration.endRecordingBlock = self.endRecordingBlock;
    return configuration;
}

@end
