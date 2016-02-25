//
//  BKRPlayableVCR.h
//  Pods
//
//  Created by Jordan Zucker on 2/9/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRVCRActions.h"
#import "BKRRequestMatching.h"

@interface BKRPlayableVCR : NSObject <BKRVCRActions>

/**
 *  This is the matcher object created during class initialization. It is
 *  used internally by the internal BKRPlayer instance to create the stubs
 *  used in playing back network operations.
 */
@property (nonatomic, strong, readonly) id<BKRRequestMatching> matcher;

@end
