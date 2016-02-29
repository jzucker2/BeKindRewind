//
//  BKRPlayheadMatcherTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 2/25/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRCassette.h>
#import <BeKindRewind/BKRScene+Playable.h>
#import <BeKindRewind/BKRPlayheadMatcher.h>
#import "BKRMatcherTestCase.h"
#import "XCTestCase+BKRHelpers.h"

@interface BKRPlayheadMatcherTestCase : BKRMatcherTestCase
@property (nonatomic, strong) BKRPlayheadMatcher *matcher;
@property (nonatomic, strong) NSArray<BKRScene *> *scenes;
@end

@implementation BKRPlayheadMatcherTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.matcher = [BKRPlayheadMatcher matcher];
    XCTAssertNotNil(self.matcher);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//- (void)testExample {
//    // This is an example of a functional test case.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
