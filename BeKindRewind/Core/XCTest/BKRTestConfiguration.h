//
//  BKRTestConfiguration.h
//  Pods
//
//  Created by Jordan Zucker on 2/23/16.
//
//

#import "BKRConfiguration.h"

@class XCTestCase;

@interface BKRTestConfiguration : BKRConfiguration

+ (instancetype)defaultConfigurationWithTestCase:(XCTestCase *)testCase;
+ (instancetype)configurationWithMatcherClass:(Class<BKRRequestMatching>)matcherClass andTestCase:(XCTestCase *)testCase;

@property (nonatomic, strong) XCTestCase *currentTestCase;

@end
