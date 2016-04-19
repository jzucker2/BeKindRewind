//
//  BKRPlayheadWithTimingMatcher.h
//  Pods
//
//  Created by Jordan Zucker on 4/5/16.
//
//

#import "BKRPlayheadMatcher.h"

/**
 *  This is a provided request matcher for playback subclassed from the
 *  BKRPlayheadMatcher class. It conforms to BKRRequestMatching and 
 *  respects ordering of network requests and returns stubs in the same 
 *  order they were originally recorded. This matcher class
 *  will properly handle redirects and errors. It also returns stubs with
 *  the same request and response timing of its original recordings.
 *
 *  @note this class can easily be subclassed to adjust the rules
 *  used for matching
 *
 *  @since 2.0.0
 *
 *  @see BKRPlayheadMatcher
 */
@interface BKRPlayheadWithTimingMatcher : BKRPlayheadMatcher
@end
