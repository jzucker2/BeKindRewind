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
 *
 *  @since 1.0.0
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
 *
 *  @since 1.0.0
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
 *
 *  @since 1.0.0
 */
+ (instancetype)configurationWithMatcherClass:(Class<BKRRequestMatching>)matcherClass andTestCase:(XCTestCase *)testCase;

/**
 *  Current XCTestCase that the configuration object is meant to be used in
 *
 *  @since 1.0.0
 */
@property (nonatomic, strong) XCTestCase *currentTestCase;

/**
 *  This timeout is used for the expectation during the setUp method of
 *  the BKRTestCase in which the BKRTestVCR instance created by this
 *  configuration executes. Default value is 15 seconds.
 *
 *  @note This value must be greater than 0. If it is not than the
 *        default value is set instead.
 *
 *  @since 1.0.0
 */
@property (nonatomic, assign) NSTimeInterval setUpExpectationTimeout;

/**
 *  This timeout is used for the expectation during the tearDown method of
 *  the BKRTestCase in which the BKRTestVCR instance created by this 
 *  configuration executes. Default value is 15 seconds.
 *
 *  @note This value must be greater than 0. If it is not than the 
 *        default value is set instead.
 *
 *  @since 1.0.0
 */
@property (nonatomic, assign) NSTimeInterval tearDownExpectationTimeout;

@end
