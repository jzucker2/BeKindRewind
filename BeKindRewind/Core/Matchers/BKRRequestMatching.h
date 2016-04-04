//
//  BKRRequestMatching.h
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import <Foundation/Foundation.h>
// imported to simplify building matchers
#import "BKRResponseStub.h"
#import "BKRScene+Playable.h"
#import "BKRRedirectFrame.h"
#import "BKRRequestFrame.h"
#import "BKRPlayhead.h"
#import "NSURLRequest+BKRAdditions.h"


/**
 *  This protocol is adopted by the object used to construct the rules for network
 *  request playback matching performed by the BKRPlayer. This is where you should
 *  define the rules used to match network requests during playback.
 *
 *  @since 1.0.0
 */
@protocol BKRRequestMatching <NSObject>

/**
 *  This is used as the constructor of the matcher, it must be provided.
 *  @note Typically you can just provide a standard init like `self = [super init];`
 *
 *  @return instance of a matcher class conforming to this protocol
 *
 *  @since 1.0.0
 */
+ (id<BKRRequestMatching>)matcher;

/**
 *  This is used to create the stubbed response for a request that is expecting to be mocked.
 *  When this block executes, the test block will have already passed.
 *  @warning undefined if nil is returned.
 *
 *  @param request  request which is to receive a mocked response
 *  @param playhead this object tracks everything that occurs during a playing session.
 *
 *  @return a BKRResponseStub that mocks the network activity for this request.
 *
 *  @since 1.0.0
 */
- (BKRResponseStub *)matchForRequest:(NSURLRequest *)request withPlayhead:(BKRPlayhead *)playhead;

/**
 *  This is used by the test block to check whether a stubbed response should be provided for
 *  a request.
 *
 *  @param request  possible request to stub
 *  @param playhead this object tracks everything that occurs during a playing session.
 *
 *  @return whether or not to stub the request. If NO is returned, then the request is not stubbed
 *  and continues live and uninterrupted. If YES is returned then this request will be stubbed with
 *  the BKRResponseStub returned by `matchForRequest:withPlayhead:`.
 *
 *  @since 1.0.0
 */
- (BOOL)hasMatchForRequest:(NSURLRequest *)request withPlayhead:(BKRPlayhead *)playhead;

@optional

/**
 *  If the matcher class stores information between recordings, then this can be 
 *  implemented to reset matcher state. This can be expected to be called 
 *  whenever the VCR calls reset
 *
 *  @since 1.0.0
 */
- (void)reset;

/**
 *  This can be used to refine the matcher used in the NSURLRequest+BKRAdditions category. 
 *  This should be passed in as the options parameter to the method
 *  `BKR_isEquivalentToRequestFrame:(BKRRequestFrame *)requestFrame options:(NSDictionary *)options`
 *
 *  @return dictionary containing keys matching the constants in NSURLRequest+BKRAdditions header
 *
 *  @since 1.0.0
 */
- (NSDictionary *)requestComparisonOptions;

@end
