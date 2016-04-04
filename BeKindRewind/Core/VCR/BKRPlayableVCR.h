//
//  BKRPlayableVCR.h
//  Pods
//
//  Created by Jordan Zucker on 2/9/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRVCRActions.h"

/**
 *  This is object conforms to BKRVCRActions protocol and can only play back network sessions
 *  from its contained BKRCassette instance
 *
 *  @since 1.0.0
 */
@interface BKRPlayableVCR : NSObject <BKRVCRActions>
@end
