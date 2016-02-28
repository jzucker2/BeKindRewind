//
//  BKRAnyMatcher.h
//  Pods
//
//  Created by Jordan Zucker on 2/25/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRRequestMatching.h"

/**
 *  This conforms to BKRRequestMatching for use in playing bakc network requests. It will
 *  match any request on a cassette to a live request if they have matching originalRequest 
 *  URL absolute strings.
 *
 *  @note this class can easily be subclassed to adjust the rules
 *  used for matching
 */
@interface BKRAnyMatcher : NSObject <BKRRequestMatching>

@end
