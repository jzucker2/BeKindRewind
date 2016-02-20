//
//  NSObject+BKRVCRAdditions.h
//  Pods
//
//  Created by Jordan Zucker on 2/19/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRVCRActions.h"

@interface NSObject (BKRVCRAdditions)

- (void)BKR_executeCassetteHandlingBlockWithFinalResult:(BOOL)finalResult andCassetteFilePath:(NSString *)cassetteFilePath onMainQueue:(BKRCassetteHandlingBlock)cassetteHandlingBlock;

@end
