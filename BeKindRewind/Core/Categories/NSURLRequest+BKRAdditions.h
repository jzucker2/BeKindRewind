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
 *  well as the items. This is ignored if @"queryItems" is included in the NSArray
 *  assigned to kBKRIgnoreNSURLComponentsPropertiesOptionsKey or to
 *  kBKRIgnoreNSURLComponentsPropertiesOptionsKey. By default, query items order will
 *  be ignored unless this is overridden with a @NO (though a @YES can be provided
 *  to ensure desired behavior).
 *
 *  @since 1.0.0
 */
extern NSString * kBKRShouldIgnoreQueryItemsOrderOptionsKey;

/**
 *  This key is used in the options dictionary. It should only have a NSArray
 *  containing NSString instances. Every NSString instance contained within 
 *  the NSArray object will be ignored when comparing query items between the 
 *  two requests. Each NSString instance should be the name associated with a
 *  NSURLQueryItem from the requests. This is ignored if @"queryItems" is 
 *  included in the NSArray assigned to 
 *  kBKRIgnoreNSURLComponentsPropertiesOptionsKey or to
 *  kBKRIgnoreNSURLComponentsPropertiesOptionsKey
 *
 *  @since 1.0.0
 */
extern NSString * kBKRIgnoreQueryItemNamesOptionsKey;

/**
 *  This key is used in the options dictionary. It should only have a NSArray
 *  containing NSString instances. Every NSString instance contained within
 *  the NSArray object will be ignored when comparing components within the
 *  the requests. The available components are found within the NSURLComponents class.
 *
 *  @since 1.0.0
 */
extern NSString * kBKRIgnoreNSURLComponentsPropertiesOptionsKey;

/**
 *  This key is used in the options dictionary. It should only have a NSNumber
 *  wrapped BOOL value. If this value is `YES` then the body of the requests is 
 *  compared. If `NO` then body of the requests are not compared.
 *
 *  @since 1.0.0
 */
extern NSString * kBKRCompareHTTPBodyOptionsKey;

/**
 *  This key is used to override the matching behavior for a specified 
 *  NSURLComponent property. It should only have an NSArray containing 
 *  NSString instances as its value. The available components are found 
 *  within the NSURLComponents class. If the same key is present in the
 *  kBKRIgnoreNSURLComponentsPropertiesOptionsKey array then that intersecting key 
 *  will be ignored. Any values present in the array stored with this key
 *  should be processed in the BKRRequestMatching protocol by the optional
 *  method `hasMatchForURLComponent: withRequestComponentValue: possibleMatchComponentValue:`
 *
 *  @since 2.2.0
 */
extern NSString * kBKROverrideNSURLComponentsPropertiesOptionsKey;

typedef BOOL (^BKRURLComponentComparisonBlock)(NSString *componentName, id requestComponentValue, id otherRequestComponentValue);

@class BKRRequestFrame;
@class BKRResponseFrame;

/**
 *  This category contains helper methods for comparing NSURLRequest instances.
 *  It is intended to be used by a matcher conforming to the BKRRequestMatching
 *  protocol.
 *
 *  @since 1.0.0
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
 *
 *  @since 1.0.0
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
 *
 *  @since 1.0.0
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
 *
 *  @since 1.0.0
 */
- (BOOL)BKR_isEquivalentToRequestURLString:(NSString *)otherRequestURLString options:(NSDictionary *)options;

- (BOOL)BKR_isEquivalentToResponseFrame:(BKRResponseFrame *)responseFrame options:(NSDictionary *)options;

- (BOOL)BKR_isEquivalentForURLComponents:(NSArray<NSString *> *)URLComponents toOtherRequestURLString:(NSString *)otherRequestURLString withComparisonBlock:(BKRURLComponentComparisonBlock)componentComparisonBlock;

@end
