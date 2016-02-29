//
//  BKRTesting.h
//  Pods
//
//  Created by Jordan Zucker on 2/6/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRTestVCRActions.h"

@class BKRTestConfiguration;

/**
 *  This protocol provides the structure necessary for proper BeKindRewind network recording
 *  and stubbing during a XCTest run. Use this protocol as a guide if you need to implement
 *  your own XCTestCase subclass that utilizes BeKindRewind
 */
@protocol BKRTesting <NSObject>

/**
 *  This method determines whether the test case will record or stub all network requests.
 *  If this method returns a YES then it __(save to the location specified by ___ method).
 *  If this method returns a NO then it will expect to have a BKRPlayableCassette provided
 *  for stubbing methods.
 *
 *  @note this needs to be fleshed out when test subclass is finished
 *
 *  @return YES means network requests are recorded and NO means that network requests are 
 *  stubbed. NO is returned by default unless overridden. This should be NO for continuous 
 *  integration so that requests are stubbed during automated testing
 */
- (BOOL)isRecording; // default is YES so that it runs during dev for new classes

/**
 *  This is the matcher class used to stub responses to requests during playback. This is
 *  only utilizied if isRecording returns NO. This is where you can define the rules to
 *  use for stubbing responses. The default matcher class is BKRPlayheadMatcher
 *
 *  @return class conforming to BKRRequestMatching protocol
 */
- (BKRTestConfiguration *)testConfiguration;

/**
 *  This object conforms to the BKRTestVCRActions protocol. It used by the object conforming
 *  to this protocol to peform BeKindRewind actions
 *
 *  @param configuration this passes in the BKRTestConfiguration that is returned by testConfiguration
 *
 *  @return an object conforming to BKRTestVCRActions
 */
- (id<BKRTestVCRActions>)testVCRWithConfiguration:(BKRTestConfiguration *)configuration;

/**
 *  This is the object created by testVCRWithConfiguration:
 */
@property (nonatomic, strong, readonly) id<BKRTestVCRActions>currentVCR;

/**
 *  This is the base directory to search for the NSBundle instances containing fixtures
 *
 *  @return full path to start the search for fixture NSBundle instances
 */
- (NSString *)baseFixturesDirectoryFilePath;

/**
 *  File path to use for writing the recordings created when `[self isRecording]` 
 *  returns YES during the XCTestCase execution. This is only expected to be 
 *  called if `[self isRecording]` returns NO
 *
 *  @param baseDirectoryFilePath this is passed in during test execution by 
 *                               the result of `[self baseFixturesDirectoryFilePath]`
 *
 *  @return the full path of where to save recordings to on disk at the end of the run
 */
- (NSString *)recordingCassetteFilePathWithBaseDirectoryFilePath:(NSString *)baseDirectoryFilePath;

/**
 *  This is an instance of BKRCassette used to stub network events for playing.
 *  This is only expected to be called if `[self isRecording]` returns YES
 *
 *  @return fully created instance of BKRCassette containing any recordings to be used for playing
 */
- (BKRCassette *)playingCassette;

/**
 *  This is an instance of BKRCassette used to record network events for later playback. This 
 *  is only expected to be called if `[self isRecording]` returns NO. Expected to return a 
 *  blank instance of BKRCassette like `[BKRCassette cassette]`
 *
 *  @return fully created instance of BKRCassette to store network events on
 */
- (BKRCassette *)recordingCassette;

@end
