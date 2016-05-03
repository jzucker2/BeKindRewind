//
//  NSObject+BKRRequestMatchingAdditions.h
//  Pods
//
//  Created by Jordan Zucker on 5/3/16.
//
//

#import <Foundation/Foundation.h>

@class BKRScene;

@interface NSObject (BKRRequestMatchingAdditions)

- (BOOL)BKR_overrideForRequest:(NSURLRequest *)request matchesRequestURLString:(NSString *)requestURLString withOptions:(NSDictionary *)options;

@end
