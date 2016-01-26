//
//  BKRFilePathHelper.h
//  Pods
//
//  Created by Jordan Zucker on 1/26/16.
//
//

#import <Foundation/Foundation.h>

/**
 *  Collection of class methods for dealing with file system loading and saving
 */
@interface BKRFilePathHelper : NSObject

// returns nil if there is no path
// pass in class like this: self.class
+ (NSString *)findPathForFile:(NSString *)fileName inBundleForClass:(Class)classInBundle;

+ (NSDictionary *)dictionaryForPlistFile:(NSString *)fileName inBundleForClass:(Class)classInBundle;

@end
