//
//  NSURLComponents+BKRAdditions.h
//  Pods
//
//  Created by Jordan Zucker on 4/27/16.
//
//

#import <Foundation/Foundation.h>

@interface NSURLComponents (BKRAdditions)

/**
 *  This returns an NSArray of all the properties for NSURLComponents
 *
 *  @return NSArray of NSString values
 *
 *  @since 2.2.0
 */
+ (NSArray<NSString *> *)BKR_URLComponentsProperties;

/**
 *  This returns an array of the NSURLComponents that will be compared using 
 *  the default methods of BeKindRewind (string matching).
 *
 *  @param options This is an NSDictionary of the options for comparing objects.
 *
 *  @return NSArray of NSString instances that are valid NSURLComponent property keys
 *
 *  @since 2.2.0
 */
+ (NSArray<NSString *> *)BKR_defaultComparingURLComponentsProperties:(NSDictionary *)options;

/**
 *  This returns an array of the NSURLComponents that are going to be overridden, taking into
 *  account any properties that are being ignored.
 *
 *  @param options This is an NSDictionary of the options for comparing objects.
 *
 *  @return NSArray of NSString instances that are valid NSURLComponent property keys
 *
 *  @since 2.2.0
 */
+ (NSArray<NSString *> *)BKR_overridingComparingURLComponentsProperties:(NSDictionary *)options;

/**
 *  This determines whether there are any properties of NSURLComponents to compare, including overrides.
 *
 *  @param options This is the options dictionary that determines what values are applied to matching
 *
 *  @return If `YES` then there are properties to compare. If `NO`
 *          then there are no properties to compare.
 *
 *  @since 2.2.0
 */
+ (BOOL)BKR_shouldCompareURLComponentsProperties:(NSDictionary *)options;

/**
 *  This determines whether there are any properties of NSURLComponents that will
 *  be overridden
 *
 *  @param options This is the options dictionary that determines what values are applied to matching
 *
 *  @return If `YES` then there are properties to override in comparison. If `NO`
 *          then there are no properties to override in comparison.
 *
 *  @since 2.2.0
 */
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

/**
 *  This compares two NSURLComponent values for two requests
 *
 *  @param componentString      this is an NSString of a part of a URL
 *  @param otherComponentString this is an NSString of a part of a different URL
 *
 *  @return Returns `YES` if the two components match or are both nil and `NO` if they do not
 *          match or only one is nil
 *
 *  @since 2.2.0
 */
+ (BOOL)BKR_componentString:(NSString *)componentString matchesOtherComponentString:(NSString *)otherComponentString;

@end
