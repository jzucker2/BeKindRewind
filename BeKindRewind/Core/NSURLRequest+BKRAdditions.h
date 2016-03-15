//
//  NSURLRequest+BKRAdditions.h
//  Pods
//
//  Created by Jordan Zucker on 3/14/16.
//
//

#import <Foundation/Foundation.h>

extern NSString * kBKRShouldIgnoreQueryItemsOrder;
extern NSString * kBKRIgnoreQueryItemNames;
extern NSString * kBKRIgnoreNSURLComponentsProperties;

@interface NSURLRequest (BKRAdditions)

/**
 *  Compare receiver to another NSURLRequest instance.
 *
 *  @param otherRequest Another instance of NSURLRequest to compare with
 *  @param options      Include options such as ignore query item order or 
 *                      ignore specific query items. Or ignore a specific NSURLComponents property
 *
 *  @return whether or not the two instances of NSURLRequest are equal, after considering the options.
 */
- (BOOL)BKR_isEquivalentToRequest:(NSURLRequest *)otherRequest options:(NSDictionary *)options;

@end
