//
//  XCTestCase+BKRHelpers.h
//  BeKindRewind
//
//  Created by Jordan Zucker on 2/16/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface BKRExpectedTestResult : NSObject
@property (nonatomic, copy) NSString *URLString;
@property (nonatomic, copy) NSString *HTTPMethod;
@end

@interface XCTestCase (BKRHelpers)



@end
