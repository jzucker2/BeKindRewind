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

//typedef BKRCassette *(^BKRTestVCRCassetteLoadingBlock)(XCTestCase *testCase);
//typedef NSString *(^BKRTestVCRCassetteSavingBlock)(BKRCassette *cassette, XCTestCase *testCase);

/**
 *  This protocol defines the actions used by the BKRTestCase class to run BeKindRewind network recording
 *  and mocking tests. If you would like to subclass your own VCR object for testing and use the provided
 *  BKRTestCase subclass, make sure to fully implement this protocol. It is important to protect asynchronous
 *  execution with proper usage of XCTestExpectation
 */
@protocol BKRTestVCRActions <BKRVCRActions>

/**
 *  Designated initializer for creating a test VCR instance conforming to this protocol
 *
 *  @param configuration contains the configuration options to use for creating the object
 *
 *  @return newly initialized instance conforming to BKRTestVCRActions
 */
- (instancetype)initWithTestConfiguration:(BKRTestConfiguration *)configuration;

/**
 *  Convenience initializer for creating a test VCR instance conforming to this protocol
 *
 *  @param configuration contains the configuration options to use for creating the object
 *
 *  @return newly initialized instance conforming to BKRTestVCRActions
 */
+ (instancetype)vcrWithTestConfiguration:(BKRTestConfiguration *)configuration;

/**
 *  Convenience initializer for creating an object conforming to this protocol. This method
 *  should use `[BKRTestConfiguration defaultConfigurationWithTestCase:]` to create the instance.
 *
 *  @param configuration contains the configuration options to use for creating the object
 *
 *  @return newly initialized instance conforming to BKRTestVCRActions
 */
+ (instancetype)defaultVCRForTestCase:(XCTestCase *)testCase;

/**
 *  Begin playing network events from the contained BKRCassette 
 *  instance. This generates an XCTestExpectation internally.
 */
- (void)play;

/**
 *  This disables playing or recording if either is occurring but will not allow a switch between
 *  those two states. This generates an XCTestExpectation internally.
 */
- (void)pause;

/**
 *  Stop playing or recording and allow a switch between those two states if desired. 
 *  This generates an XCTestExpectation internally.
 */
- (void)stop;

/**
 *  This resets the state of the receiver to BKRVCRStateStopped and removes 
 *  any contained BKRCassette instance. This generates an XCTestExpectation internally.
 */
- (void)reset;

/**
 *  This inserts a BKRCassette into the receiver. This generates an XCTestExpectation internally.
 *
 *  @param cassetteLoadingBlock block to be executed on the receiver's custom queue
 *
 *  @return YES if the cassette is properly loaded
 */
- (BOOL)insert:(BKRVCRCassetteLoadingBlock)cassetteLoadingBlock;

/**
 *  This removes a cassette and writes the contents to a file path returned by the cassetteSavingBlock 
 *  passed in. This generates an XCTestExpectation internally.
 *
 *  @param cassetteSavingBlock block to be executed on the receiver's custom queue
 *
 *  @return YES if the cassette is saved to the file path, NO if the write fails
 */
- (BOOL)eject:(BKRVCRCassetteSavingBlock)cassetteSavingBlock;

/**
 *  Begin recording network events onto the contained BKRCassette
 *  instance. This generates an XCTestExpectation internally.
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
 *  @since 0.9
 */
- (BKRTestConfiguration *)currentConfiguration;

@end
