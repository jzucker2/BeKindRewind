//
//  BKRPlayheadMatcher.h
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRRequestMatching.h"

/**
 *  This is a provided simple request matcher for playback. It conforms to 
 *  BKRRequestMatching and respects ordering of network requests and returns
 *  stubs in the same order they were originally recorded.
 *  
 *  @note this class can easily be subclassed to adjust the rules
 *  used for matching
 */
@interface BKRPlayheadMatcher : NSObject <BKRRequestMatching>

@end
