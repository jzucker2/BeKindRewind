//
//  BKRVCRTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/27/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRVCR.h>
#import <BeKindRewind/BKRFilePathHelper.h>
#import <BeKindRewind/NSURLSessionTask+BKRAdditions.h>
#import <BeKindRewind/NSURLSessionTask+BKRTestAdditions.h>
#import <BeKindRewind/BKRPlayheadMatcher.h>
#import "XCTestCase+BKRHelpers.h"
#import "BKRBaseTestCase.h"

@interface BKRVCRTestCase : BKRBaseTestCase
@property (nonatomic, strong) BKRVCR *vcr;
@property (nonatomic, copy) NSString *testRecordingFilePath;
@property (nonatomic, copy) NSString *testPlayingFilePath;
@end

@implementation BKRVCRTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

@end
