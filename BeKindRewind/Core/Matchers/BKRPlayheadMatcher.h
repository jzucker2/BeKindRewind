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
 *  stubs in the same order they were originally recorded. This matcher class
 *  will properly handle redirects and errors.
 *  
 *  @note this class can easily be subclassed to adjust the rules
 *  used for matching
 *
 *  @since 1.0.0
 */
@interface BKRPlayheadMatcher : NSObject <BKRRequestMatching>
@end
