//
//  BKRTestCase.h
//  Pods
//
//  Created by Jordan Zucker on 1/26/16.
//
//

#import <XCTest/XCTest.h>
#import "BKRTesting.h"

/**
 *  This is a provided XCTestCase subclass for easy network recording and stubbing. It conforms
 *  to the BKRTesting protocol and does all of the necessary configuration for easy usage of
 *  BeKindRewind. Use this implementation as a guide if you need to implement BeKindRewind into
 *  your own XCTestCase subclass.
 *
 *  @since 1.0.0
 */
@interface BKRTestCase : XCTestCase <BKRTesting>
@end
