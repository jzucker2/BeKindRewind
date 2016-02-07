//
//  BKRFilePathHelper.h
//  Pods
//
//  Created by Jordan Zucker on 1/26/16.
//
//

#import <Foundation/Foundation.h>

/**
 *  Collection of class methods for dealing with file system loading and saving. There is no
 *  object created, these class helpers do not need to persist information between calls.
 */
@interface BKRFilePathHelper : NSObject

// returns nil if there is no path
// pass in class like this: self.class

/**
 *  Find path for file contained in NSBundle that also contains the provided class
 *
 *  @param fileName      expected file name to find path for
 *  @param classInBundle bundle to search in that also contains class. Pass in like this `self.class`
 *
 *  @return full path for file contained in bundle also containing class or nil if file is not found
 */
+ (NSString *)findPathForFile:(NSString *)fileName inBundleForClass:(Class)classInBundle;

/**
 *  Find full path for file contained in the specified NSBundle
 *
 *  @param fileName file name to search for
 *  @param bundle   bundle to search for file in
 *
 *  @return full path for file contained in bundle or nil if no file is found
 */
+ (NSString *)findPathForFile:(NSString *)fileName inBundle:(NSBundle *)bundle;

/**
 *  Find NSBundle contained within the NSBundle that also contains the provided class
 *
 *  @param bundleName    name of bundle to search for
 *  @param classInBundle bundle to search in that also contains class. Pass in like this `self.class`
 *
 *  @return bundle object
 */
+ (NSBundle *)findBundle:(NSString *)bundleName containingClass:(Class)classInBundle;

/**
 *  Find the full path for a file contained with a bundle that is contained within a bundle that
 *  that holds the provided class
 *
 *  @param fileName      name of file to search for
 *  @param bundleName    name of bundle to search for
 *  @param classInBundle bundle to search in that also contains class. Pass in like this `self.class`
 *
 *  @return full path of file or nil if file or bundle does not exist
 */
+ (NSString *)findPathForFile:(NSString *)fileName inBundle:(NSString *)bundleName inBundleForClass:(Class)classInBundle;

+ (NSDictionary *)dictionaryForPlistFilePath:(NSString *)filePath;

// this is the most important retrieving method, others are public in case people want to get creative.
// also exposed for testing. but this is what you should be using
// bundleName is the bundle stored in the project (containing the plists to use)
// for last param, pass in `self.class`
+ (NSDictionary *)dictionaryForPlistFile:(NSString *)fileName inBundle:(NSString *)bundleName inBundleForClass:(Class)classInBundle;

+ (NSString *)fixtureWriteDirectoryInProject;

+ (BOOL)writeDictionary:(NSDictionary *)dictionary toFile:(NSString *)filePath;

/**
 *  Documents directory of device currently executing target (either on OSX device or iOS device, etc).
 *
 *  @return full path of documents directory
 */
+ (NSString *)documentsDirectory;

// pass in bundle name without .bundle extension. It is added automatically
// intended to be used by test classe
+ (NSBundle *)writingBundleNamed:(NSString *)bundleName inDirectory:(NSString *)filePath;



@end
