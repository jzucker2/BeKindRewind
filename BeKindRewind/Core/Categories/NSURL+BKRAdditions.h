//
//  NSURL+BKRAdditions.h
//  Pods
//
//  Created by Jordan Zucker on 3/17/16.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  This has additions used for interacting with NSURL instances within BeKindRewind.
 */
@interface NSURL (BKRAdditions)

/**
 *  Returns a URL containing everything up until the path component.
 *
 *  @return a base URL only containing everything up until the path component.
 */
- (nullable instancetype)BKR_baseURL;

/**
 *  Creates a base URL from the absoluteURL provided. This will be the URL up to the path component.
 *
 *  @param absoluteURL URL to create the base URL from
 *
 *  @return a base URL only containing everything up until the path component.
 */
+ (nullable instancetype)BKR_baseURLFromAbsoluteURL:(nullable NSURL *)absoluteURL;

@end

NS_ASSUME_NONNULL_END
