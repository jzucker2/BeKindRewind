//
//  BKRRecordableVCR.h
//  Pods
//
//  Created by Jordan Zucker on 2/9/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRVCRActions.h"

/**
 *  This is object conforms to BKRVCRActions protocol and can only record network sessions
 *  onto the contained BKRCassette instance
 */
@interface BKRRecordableVCR : NSObject <BKRVCRActions>

@end
