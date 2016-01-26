//
//  BKRTestCase.h
//  Pods
//
//  Created by Jordan Zucker on 1/26/16.
//
//

#import <XCTest/XCTest.h>
#import "BKRRequestMatching.h"

@interface BKRTestCase : XCTestCase

- (BOOL)isRecording;
- (Class<BKRRequestMatching>)matcherClass;

@end
