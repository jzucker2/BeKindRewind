//
//  BKRTestVCRTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 2/21/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <BeKindRewind/BKRTestVCR.h>
#import "BKRBaseTestCase.h"
#import "XCTestCase+BKRHelpers.h"

@interface BKRTestVCRTestCase : BKRBaseTestCase
@property (nonatomic, strong) BKRTestVCR *vcr;
@end

@implementation BKRTestVCRTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

@end
