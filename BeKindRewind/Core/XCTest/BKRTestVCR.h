//
//  BKRTestVCR.h
//  Pods
//
//  Created by Jordan Zucker on 2/7/16.
//
//

#import "BKRVCR.h"

@class XCTestCase;

/**
 *  This is simple subclass of BKRVCR that simplifies usage in XCTestCase for easy testing.
 */
@interface BKRTestVCR : BKRVCR

/**
 *  The test case that needs to have its network operations recorded or stubbed.
 */
@property (nonatomic, strong) XCTestCase *currentTestCase;

@end
