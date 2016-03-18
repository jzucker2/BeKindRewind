//
//  NSURL+BKRAdditions.h
//  Pods
//
//  Created by Jordan Zucker on 3/17/16.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (BKRAdditions)

- (nullable instancetype)BKR_baseURL;
+ (nullable instancetype)BKR_baseURLFromAbsoluteURL:(nullable NSURL *)absoluteURL;

@end

NS_ASSUME_NONNULL_END
