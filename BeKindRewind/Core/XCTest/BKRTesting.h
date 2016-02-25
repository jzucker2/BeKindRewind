//
//  BKRTesting.h
//  Pods
//
//  Created by Jordan Zucker on 2/6/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRRequestMatching.h"
#import "BKRTestVCRActions.h"

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
- (BOOL)isRecording;

/**
 *  This is the matcher class used to stub responses to requests during playback. This is
 *  only utilizied if isRecording returns NO. This is where you can define the rules to
 *  use for stubbing responses. The default matcher class is BKRPlayheadMatcher
 *
 *  @return class conforming to BKRRequestMatching protocol
 */
- (Class<BKRRequestMatching>)matcherClass;

@property (nonatomic, strong, readonly) id<BKRTestVCRActions>vcr;

@end
