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

typedef BKRCassette *(^BKRTestVCRCassetteLoadingBlock)(XCTestCase *testCase);
typedef NSString *(^BKRTestVCRCassetteSavingBlock)(BKRCassette *cassette, XCTestCase *testCase);

@protocol BKRTestVCRActions <NSObject>

- (void)play;
- (void)pause;
- (void)stop;
- (void)reset;
- (BOOL)insert:(BKRTestVCRCassetteLoadingBlock)cassetteLoadingBlock;
- (BOOL)eject:(BKRTestVCRCassetteSavingBlock)cassetteSavingBlock;
- (void)record;

/**
 *  The test case that needs to have its network operations recorded or stubbed.
 */
@property (nonatomic, strong) XCTestCase *currentTestCase;

@end
