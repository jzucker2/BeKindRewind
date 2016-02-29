//
//  BKRTestConfiguration.h
//  Pods
//
//  Created by Jordan Zucker on 2/23/16.
//
//

#import "BKRConfiguration.h"

@class XCTestCase;

/**
 *  This is a subclass of BKRConfiguration that also contains 
 *  a reference to the current XCTestCase executing.
 */
@interface BKRTestConfiguration : BKRConfiguration

/**
 *  Convenience initializer that creates an instance from `defaultConfiguration` 
 *  and requires a XCTestCase instance for initialization.
 *
 *  @param testCase currently executing XCTestCase instance. Expected to be used in 
 *                  an XCTestCase subclass. Typically pass in `self`
 *
 *  @return newly initialized instance of BKRTestConfiguration
 */
+ (instancetype)defaultConfigurationWithTestCase:(XCTestCase *)testCase;

/**
 *  Convenience initializer that creates an instance using a matcherClass 
 *  conforming to BKRRequestMatching and requires a XCTestCase instance 
 *  for initialization.
 *
 *  @param testCase currently executing XCTestCase instance. Expected to be used in
 *                  an XCTestCase subclass. Typically pass in `self`
 *
 *  @return newly initialized instance of BKRTestConfiguration
 */
+ (instancetype)configurationWithMatcherClass:(Class<BKRRequestMatching>)matcherClass andTestCase:(XCTestCase *)testCase;

/**
 *  Current XCTestCase that the configuration object is meant to be used in
 */
@property (nonatomic, strong) XCTestCase *currentTestCase;

@end
