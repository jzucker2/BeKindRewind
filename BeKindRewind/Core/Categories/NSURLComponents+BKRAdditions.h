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


+ (NSArray<NSString *> *)BKR_defaultComparingURLComponentsProperties:(NSDictionary *)options;

+ (NSArray<NSString *> *)BKR_overridingComparingURLComponentsProperties:(NSDictionary *)options;

+ (BOOL)BKR_shouldCompareURLComponentsProperties:(NSDictionary *)options;

+ (BOOL)BKR_shouldOverrideComparingURLComponentsProperties:(NSDictionary *)options;

/**
 *  This safely accesses the options dictionary for comparing NSURLRequest instances 
 *  and components. It fetches the NSURLComponent properties listed in the array for 
 *  kBKROverrideNSURLComponentsPropertiesOptionsKey in the options dictionary. It will
 *  return an empty array if the key is not present in options.
 *
 *  @see NSURLRequest (BKRAdditions)
 *
 *  @param options This is an NSDictionary of the options for comparing objects. If 
 *                 this is null then an empty array will be returned.
 *
 *  @throws If there is a value stored for 
 *          kBKROverrideNSURLComponentsPropertiesOptionsKey and it is not of type 
 *          NSArray then an NSInternalInconsistencyException is thrown
 *
 *
 *  @return an NSArray of NSURLComponent properties to override during comparison 
 *          or an empty array if there are none
 *
 *  @since 2.2.0
 */
+ (NSArray<NSString *> *)BKR_rawOverridingComparingURLComponentsProperties:(NSDictionary *)options;

/**
 *  This safely accesses the options dictionary for comparing NSURLRequest instances
 *  and components. It fetches the NSURLComponent properties listed in the array for
 *  kBKRIgnoreNSURLComponentsPropertiesOptionsKey in the options dictionary. It will
 *  return an empty array if the key is not present in options.
 *
 *  @see NSURLRequest (BKRAdditions)
 *
 *  @param options This is an NSDictionary of the options for comparing objects. If
 *                 this is null then an empty array will be returned.
 *
 *  @throws If there is a value stored for
 *          kBKRIgnoreNSURLComponentsPropertiesOptionsKey and it is not of type
 *          NSArray then an NSInternalInconsistencyException is thrown
 *
 *
 *  @return an NSArray of NSURLComponent properties to ignore during comparison
 *          or an empty array if there are none
 *
 *  @since 2.2.0
 */
+ (NSArray<NSString *> *)BKR_rawIgnoringURLComponentsProperties:(NSDictionary *)options;

//+ (BOOL)BKR_shouldIgnoreURLComponentsQueryItems:(NSDictionary *)options;
//+ (BOOL)BKR_shouldCompareURLComponentsQueryItems:(NSDictionary *)options;
//+ (BOOL)BKR_shouldOverrideURLComponentsComparisons:(NSDictionary *)options;

+ (BOOL)BKR_componentString:(NSString *)componentString matchesOtherComponentString:(NSString *)otherComponentString;

@end
