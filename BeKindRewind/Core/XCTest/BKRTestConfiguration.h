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

/**
 *  Current XCTestCase that the configuration object is meant to be used in
 */
@property (nonatomic, strong) XCTestCase *currentTestCase;

@end
