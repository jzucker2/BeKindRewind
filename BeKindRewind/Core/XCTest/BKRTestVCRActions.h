//
//  BKRTestVCRActions.h
//  Pods
//
//  Created by Jordan Zucker on 2/21/16.
//
//

#import <Foundation/Foundation.h>

@class BKRCassette;
@class XCTestCase;

//typedef BKRCassette *(^BKRTestVCRCassetteLoadingBlock)(XCTestCase *testCase);
//typedef NSString *(^BKRTestVCRCassetteSavingBlock)(BKRCassette *cassette, XCTestCase *testCase);

@protocol BKRTestVCRActions <NSObject>

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

@end
