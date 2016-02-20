//
//  NSObject+BKRVCRAdditions.m
//  Pods
//
//  Created by Jordan Zucker on 2/19/16.
//
//

#import "NSObject+BKRVCRAdditions.h"

@implementation NSObject (BKRVCRAdditions)

- (void)BKR_executeCassetteHandlingBlockWithFinalResult:(BOOL)finalResult andCassetteFilePath:(NSString *)cassetteFilePath onMainQueue:(BKRCassetteHandlingBlock)cassetteHandlingBlock {
    if (cassetteHandlingBlock) {
        if ([NSThread isMainThread]) {
            cassetteHandlingBlock(finalResult);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                cassetteHandlingBlock(finalResult);
            });
        }
    }
}

@end
