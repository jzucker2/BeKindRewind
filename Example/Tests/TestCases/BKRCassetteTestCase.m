//
//  BKRCassetteTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/27/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRPlayableCassette.h>
#import <BeKindRewind/BKRRecordableCassette.h>
#import "BKRBaseTestCase.h"
#import "XCTestCase+BKRAdditions.h"

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

- (void)testCreatePlayableCasssetteWithManyScenesPerformance {
    [self measureBlock:^{
        [self assertCreationOfPlayableCassetteWithNumberOfScenes:50];
    }];
}

@end
