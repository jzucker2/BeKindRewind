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
 *  This optional method is used by the BKRVCR instance to determine how long it should
 *  take to begin responding to a request. At this point, the request has already been matched
 *  with a stub, but there is an opportunity to customize the timing. The return value 
 *  represents the time that elapses between a request beginning and when the request begins
 *  receiving a response. If this is not implemented then there is no delay between a
 *  request and the beginning of a response.
 *
 *  @param request      the request that for which request timing is being determined
 *  @param responseStub the BKRResponseStub instance that is mocking request
 *  @param playhead     the current playhead of the BKRVCR instance
 *
 *  @return this is the time interval (in seconds) that will elapse before a response is returned.
 *
 *  @note must be set to a value greater than or equal to 0
 *
 *  @since 2.0.0
 */
- (NSTimeInterval)requestTimeForRequest:(NSURLRequest *)request withStub:(BKRResponseStub *)responseStub withPlayhead:(BKRPlayhead *)playhead;

/**
 *  This optional method is used by the BKRVCR instance to determine how long it should take
 *  to return the data associated with a response for a request. At this point, a NSURLResponse
 *  has been returned for the associated request parameter but the actual data associated with
 *  the network action has not been returned. The return value represents the amount of time
 *  (or the speed) that it takes to return all of the data for a network action. If this is
 *  not implemented then there is no delay for returning the data.
 *
 *
 *  @param request      the request for which response timing is being determined
 *  @param responseStub the BKRResponseStub instance that is mocking request
 *  @param playhead     the current playhead of the BKRVCR instance
 *
 *  @return this is the time interval (in seconds) that will elapse for for the data to be 
 *          returned for request
 *
 *  @note if responseTime<0, it is interpreted as a download speed in KBps ( -200 => 200KB/s ). There
 *        are constants provided to simulate various network speeds.
 *
 *  @since 2.0.0
 */
- (NSTimeInterval)responseTimeForRequest:(NSURLRequest *)request withStub:(BKRResponseStub *)responseStub withPlayhead:(BKRPlayhead *)playhead;

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
