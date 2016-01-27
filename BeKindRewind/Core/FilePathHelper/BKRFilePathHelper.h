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

+ (NSString *)findPathForFile:(NSString *)fileName inBundle:(NSBundle *)bundle;

+ (NSBundle *)findBundle:(NSString *)bundleName containingClass:(Class)classInBundle;

+ (NSString *)findPathForFile:(NSString *)fileName inBundle:(NSString *)bundleName inBundleForClass:(Class)classInBundle;

+ (NSDictionary *)dictionaryForPlistFilePath:(NSString *)filePath;

// this is the most important retrieving method, others are public in case people want to get creative.
// also exposed for testing. but this is what you should be using
// bundleName is the bundle stored in the project (containing the plists to use)
// for last param, pass in `self.class`
+ (NSDictionary *)dictionaryForPlistFile:(NSString *)fileName inBundle:(NSString *)bundleName inBundleForClass:(Class)classInBundle;

+ (NSString *)fixtureWriteDirectory;

@end
