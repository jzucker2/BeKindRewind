//
//  BKRCassetteTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/27/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRCassette+Playable.h>
#import <BeKindRewind/BKRCassette+Recordable.h>
#import "BKRBaseTestCase.h"
#import "XCTestCase+BKRHelpers.h"

@interface BKRCassetteTestCase : BKRBaseTestCase

@end

@implementation BKRCassetteTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCreatePlayableCassetteWithManyScenes {
    [self assertCreationOfPlayableCassetteWithNumberOfScenes:20];
}

- (void)DISABLE_testCreatePlayableCasssetteWithManyScenesPerformance {
    __weak typeof(self) wself = self;
    [self measureBlock:^{
        __strong typeof(wself) sself = wself;
        [sself assertCreationOfPlayableCassetteWithNumberOfScenes:50];
    }];
}

@end
