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

/**
 *  Find path for file contained in NSBundle that also contains the provided class
 *
 *  @param fileName      expected file name to find path for
 *  @param classInBundle bundle to search for fileName in that also contains class. 
 *                       Pass in like this `self.class`
 *
 *  @return full path for file contained in bundle also containing class or nil if file is not found
 */
+ (NSString *)findPathForFile:(NSString *)fileName inBundleForClass:(Class)classInBundle;

/**
 *  Find full path for file contained in the specified NSBundle
 *
 *  @param fileName file name to search for
 *  @param bundle   bundle to search for fileName in
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
 *  @param bundleName    name of bundle to search for containing fileName
 *  @param classInBundle bundle to search in that also contains class. Pass in like this `self.class`
 *
 *  @return full path of file or nil if file or bundle does not exist
 */
+ (NSString *)findPathForFile:(NSString *)fileName inBundle:(NSString *)bundleName inBundleForClass:(Class)classInBundle;

/**
 *  Returns a dictionary containing information necessary to create a BKRPlayableCassette instance.
 *
 *  @param filePath location of plist that serves as source of dictionary contents. Throws exception if
 *                  the filePath string does not end in ".plist" or if nil.
 *
 *  @return dictionary of Foundation objects that can create a BKRPlayableCassette instance
 */
+ (NSDictionary *)dictionaryForPlistFilePath:(NSString *)filePath;

// this is the most important retrieving method, others are public in case people want to get creative.
// also exposed for testing. but this is what you should be using
// bundleName is the bundle stored in the project (containing the plists to use)
// for last param, pass in `self.class`
/**
 *  This is the most useful method for fetching stub data at a file path and returning a dictionary
 *  that can be converted into a BKRPlayableCassette object. The other method for finding files and
 *  bundles are included for those who'd like more control, but this is the main function for 
 *  retrieving data for stubbing.
 *
 *  @param fileName      name of file to search for
 *  @param bundleName    name of bundle to search for containing fileName
 *  @param classInBundle bundle to search in that also contains class. Pass in like this `self.class`
 *
 *  @return returns dictionary of objects for creating BKRPlayableCassette instance. Throws exception 
 *  if there is no plist matching these values or if the root object of the plist is not a dictionary
 */
+ (NSDictionary *)dictionaryForPlistFile:(NSString *)fileName inBundle:(NSString *)bundleName inBundleForClass:(Class)classInBundle;

/**
 *  This is used to represent the root directory to use for saving recordings
 *  @warning untested, this can't be tested in unit tests through traditional means
 *
 *  @return full path of directory to write recordings to located within current Xcode project
 */
+ (NSString *)fixtureWriteDirectoryInProject;

/**
 *  Function for serializing a dictionary of plist encodable Foundation objects to filePath
 *
 *  @param dictionary must only contain Foundation objects that can be encoded in a plist. 
 *                    Throws exception if object is not a dictionary
 *  @param filePath   destination to write data to. Throws exception if filePath does
 *                    not end in ".plist" extension or is nil
 *
 *  @return YES if success and NO if failure
 */
+ (BOOL)writeDictionary:(NSDictionary *)dictionary toFile:(NSString *)filePath;

/**
 *  Documents directory of device currently executing target (either on OSX device or iOS device, etc).
 *
 *  @return full path of documents directory
 */
+ (NSString *)documentsDirectory;

/**
 *  Used for saving a recording session's plist information in a bundle that may exist
 *  or need to be created. Mostly intended to be used by XCTest subclasses.
 *
 *  @param bundleName name of bundle to find or create. Throws exception if this is ends 
 *                    with extension ".bundle" or is nil
 *  @param filePath   create or save bundleName at this location, creating intermediate 
 *                    directories if needed
 *
 *  @return bundle newly created or already existing if it matches criteria
 */
+ (NSBundle *)writingBundleNamed:(NSString *)bundleName inDirectory:(NSString *)filePath;

@end
