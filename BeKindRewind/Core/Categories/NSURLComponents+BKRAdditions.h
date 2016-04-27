//
//  NSURLComponents+BKRAdditions.h
//  Pods
//
//  Created by Jordan Zucker on 4/27/16.
//
//

#import <Foundation/Foundation.h>

@interface NSURLComponents (BKRAdditions)

+ (NSArray<NSString *> *)BKR_URLComponentsProperties;

+ (NSArray<NSString *> *)BKR_comparingURLComponentsProperties:(NSDictionary *)options;

// this will include ignoring properties, just a safe fetch on the options key, returns empty array if nothing should be overridden, shouldn't ever return nil
+ (NSArray<NSString *> *)BKR_overridingComparingURLComponentsProperties:(NSDictionary *)options;

// returns empty array if nothing is being ignored, shouldn't ever return nil
+ (NSArray<NSString *> *)BKR_ignoringURLComponentsProperties:(NSDictionary *)options;

+ (BOOL)BKR_shouldIgnoreURLComponentsQueryItems:(NSDictionary *)options;
+ (BOOL)BKR_shouldCompareURLComponentsQueryItems:(NSDictionary *)options;

@end
