//
//  NSURLRequest+BKRAdditions.h
//  Pods
//
//  Created by Jordan Zucker on 3/14/16.
//
//

#import <Foundation/Foundation.h>

/**
 *  This key is used in the options dictionary. It should only have a NSNumber 
 *  wrapped BOOL value. If this value is `YES` then the order of query items 
 *  in the requests to compare is ignored. If `NO` then the order is compared as 
 *  well as the items.
 */
extern NSString * kBKRShouldIgnoreQueryItemsOrder;

/**
 *  This key is used in the options dictionary. It should only have a NSArray
 *  containing NSString instances. Every NSString instance contained within 
 *  the NSArray object will be ignored when comparing query items between the 
 *  two requests. Each NSString instance should be the name associated with a
 *  NSURLQueryItem from the requests.
 */
extern NSString * kBKRIgnoreQueryItemNames;

/**
 *  This key is used in the options dictionary. It should only have a NSArray
 *  containing NSString instances. Every NSString instance contained within
 *  the NSArray object will be ignored when comparing components within the
 *  the requests. The available components are found within the NSURLComponents class.
 */
extern NSString * kBKRIgnoreNSURLComponentsProperties;

/**
 *  This key is used in the options dictionary. It should only have a NSNumber
 *  wrapped BOOL value. If this value is `YES` then the body of the requests is 
 *  compared. If `NO` then body of the requests are not compared.
 */
extern NSString * kBKRCompareHTTPBody;

@class BKRRequestFrame;

/**
 *  This category contains helper methods for comparing NSURLRequest instances.
 *  It is intended to be used by a matcher conforming to the BKRRequestMatching
 *  protocol.
 */
@interface NSURLRequest (BKRAdditions)

/**
 *  Compare receiver to another NSURLRequest instance.
 *
 *  @param otherRequest Another instance of NSURLRequest to compare with
 *  @param options      Include options such as ignore query item order or 
 *                      ignore specific query items. Or ignore a specific NSURLComponents property.
 *                      See available keys above.
 *
 *  @return whether or not the two instances of NSURLRequest are equal, after considering the options.
 */
- (BOOL)BKR_isEquivalentToRequest:(NSURLRequest *)otherRequest options:(NSDictionary *)options;

/**
 *  Compare receiver to BKRRequestFrame instance.
 *
 *  @param requestFrame A request frame object native to BeKindRewind that 
 *                      represents a recorded NSURLRequest instance.
 *  @param options      Include options such as ignore query item order or
 *                      ignore specific query items. Or ignore a specific NSURLComponents property.
 *                      See available keys above.
 *
 *  @return whether or not the two objects are equal, after considering the options.
 */
- (BOOL)BKR_isEquivalentToRequestFrame:(BKRRequestFrame *)requestFrame options:(NSDictionary *)options;

/**
 *  Compare receiver to a string representing a URL
 *
 *  @param otherRequestURLString string that represents a URL
 *  @param options               Include options such as ignore query item order or
 *                      ignore specific query items. Or ignore a specific NSURLComponents property.
 *                      See available keys above.
 *
 *  @return whether or not the two objects are equal, after considering the options.
 */
- (BOOL)BKR_isEquivalentToRequestURLString:(NSString *)otherRequestURLString options:(NSDictionary *)options;

@end
