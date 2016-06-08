//
//  BKRTestVCRActions.h
//  Pods
//
//  Created by Jordan Zucker on 2/21/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRVCRActions.h"

@class BKRTestConfiguration;
@class BKRCassette;
@class XCTestCase;

/**
 *  This protocol defines the actions used by the BKRTestCase class to run BeKindRewind network recording
 *  and mocking tests. If you would like to subclass your own VCR object for testing and use the provided
 *  BKRTestCase subclass, make sure to fully implement this protocol. It is important to protect asynchronous
 *  execution with proper usage of XCTestExpectation
 *
 *  @since 1.0.0
 */
@protocol BKRTestVCRActions <BKRVCRActions>

/**
 *  Designated initializer for creating a test VCR instance conforming to this protocol
 *
 *  @param configuration contains the configuration options to use for creating the object
 *
 *  @return newly initialized instance conforming to BKRTestVCRActions
 *
 *  @since 1.0.0
 */
- (instancetype)initWithTestConfiguration:(BKRTestConfiguration *)configuration;

/**
 *  Convenience initializer for creating a test VCR instance conforming to this protocol
 *
 *  @param configuration contains the configuration options to use for creating the test VCR object
 *
 *  @return newly initialized instance conforming to BKRTestVCRActions
 *
 *  @since 1.0.0
 */
+ (instancetype)vcrWithTestConfiguration:(BKRTestConfiguration *)configuration;

/**
 *  Convenience initializer for creating an object conforming to this protocol. This method
 *  should use `[BKRTestConfiguration defaultConfigurationWithTestCase:]` to create the instance.
 *
 *  @param testCase currently executing XCTestCase instance. Expected to be used in
 *                  an XCTestCase subclass. Typically pass in `self`
 *
 *  @return newly initialized instance conforming to BKRTestVCRActions
 *
 *  @since 1.0.0
 */
+ (instancetype)defaultVCRForTestCase:(XCTestCase *)testCase;

/**
 *  Begin playing network events from the contained BKRCassette 
 *  instance. This generates an XCTestExpectation internally.
 *
 *  @since 1.0.0
 */
- (void)play;

/**
 *  This disables playing or recording if either is occurring but will not allow a switch between
 *  those two states. This generates an XCTestExpectation internally.
 *
 *  @since 1.0.0
 */
- (void)pause;

/**
 *  Stop playing or recording and allow a switch between those two states if desired. 
 *  This generates an XCTestExpectation internally.
 *
 *  @since 1.0.0
 */
- (void)stop;

/**
 *  This resets the state of the receiver to BKRVCRStateStopped and removes 
 *  any contained BKRCassette instance. This generates an XCTestExpectation internally.
 *
 *  @since 1.0.0
 */
- (void)reset;

/**
 *  This inserts a BKRCassette into the receiver. This generates an XCTestExpectation internally.
 *
 *  @param cassetteLoadingBlock block to be executed on the receiver's custom queue
 *
 *  @return YES if the cassette is properly loaded
 *
 *  @since 1.0.0
 */
- (BOOL)insert:(BKRVCRCassetteLoadingBlock)cassetteLoadingBlock;

/**
 *  This removes a cassette and writes the contents to a file path returned by the cassetteSavingBlock 
 *  passed in. This generates an XCTestExpectation internally.
 *
 *  @param cassetteSavingBlock block to be executed on the receiver's custom queue
 *
 *  @return YES if the cassette is saved to the file path, NO if the write fails
 *
 *  @since 1.0.0
 */
- (BOOL)eject:(BKRVCRCassetteSavingBlock)cassetteSavingBlock;

/**
 *  Begin recording network events onto the contained BKRCassette
 *  instance. This generates an XCTestExpectation internally.
 *
 *  @since 1.0.0
 */
- (void)record;

/**
 *  The test case that needs to have its network operations recorded or stubbed.
 */
@property (nonatomic, strong, readonly) XCTestCase *currentTestCase;

/**
 *  Retrieve reference on current client's configuration.
 *
 *  @return Currently used configuration instance copy. Changes to this instance won't affect
 *  receiver's configuration.
 *
 *  @since 1.0.0
 */
- (BKRTestConfiguration *)currentConfiguration;

@end
