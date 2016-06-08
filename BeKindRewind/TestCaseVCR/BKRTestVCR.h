//
//  BKRTestVCR.h
//  Pods
//
//  Created by Jordan Zucker on 2/7/16.
//
//

#import "BKRVCR.h"
#import "BKRTestVCRActions.h"

@class XCTestCase;

/**
 *  This is easy subclass of BKRVCR that simplifies usage in XCTestCase for easy testing.
 *  It internally handles most XCTestExpectation related issues involved in stubbing and
 *  recording network events.
 *
 *  @since 1.0.0
 */
@interface BKRTestVCR : BKRVCR <BKRTestVCRActions>
@end
