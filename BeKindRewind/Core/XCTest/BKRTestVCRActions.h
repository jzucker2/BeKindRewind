//
//  BKRTestVCRActions.h
//  Pods
//
//  Created by Jordan Zucker on 2/21/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRVCRActions.h"

@class BKRTestConfiguration;
@class BKRCassette;
@class XCTestCase;

//typedef BKRCassette *(^BKRTestVCRCassetteLoadingBlock)(XCTestCase *testCase);
//typedef NSString *(^BKRTestVCRCassetteSavingBlock)(BKRCassette *cassette, XCTestCase *testCase);

@protocol BKRTestVCRActions <BKRVCRActions>

- (instancetype)initWithTestConfiguration:(BKRTestConfiguration *)configuration;
+ (instancetype)vcrWithTestConfiguration:(BKRTestConfiguration *)configuration;
+ (instancetype)defaultVCRForTestCase:(XCTestCase *)testCase;

- (void)play;
- (void)pause;
- (void)stop;
- (void)reset;
- (BOOL)insert:(BKRVCRCassetteLoadingBlock)cassetteLoadingBlock;
- (BOOL)eject:(BKRVCRCassetteSavingBlock)cassetteSavingBlock;
- (void)record;

/**
 *  The test case that needs to have its network operations recorded or stubbed.
 */
@property (nonatomic, strong, readonly) XCTestCase *currentTestCase;

- (BKRTestConfiguration *)currentConfiguration; // changing this won't affect the current instance created by the configuration

@end
