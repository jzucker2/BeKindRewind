//
//  BKRFilePathHelper.m
//  Pods
//
//  Created by Jordan Zucker on 1/26/16.
//
//

#import "BKRFilePathHelper.h"

@implementation BKRFilePathHelper

+ (NSString *)findPathForFile:(NSString *)fileName inBundleForClass:(Class)classInBundle {
    NSBundle *bundle = [NSBundle bundleForClass:classInBundle];
    return [self findPathForFile:fileName inBundle:bundle];
}

+ (NSString *)findPathForFile:(NSString *)fileName inBundle:(NSBundle *)bundle {
    return [bundle pathForResource:fileName.stringByDeletingPathExtension ofType:fileName.pathExtension];
}

+ (NSBundle *)findBundle:(NSString *)bundleName containingClass:(Class)classInBundle {
    NSBundle *classBundle = [NSBundle bundleForClass:classInBundle];
    return [NSBundle bundleWithPath:[classBundle pathForResource:bundleName ofType:@"bundle"]];
}

+ (NSDictionary *)dictionaryForPlistFilePath:(NSString *)filePath {
    NSParameterAssert(filePath);
    NSParameterAssert([filePath.pathExtension isEqualToString:@"plist"]);
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    NSAssert([dictionary isKindOfClass:[NSDictionary class]], @"Plist root object must be a dictionary, not %@", dictionary.class);
    return dictionary;
}

+ (NSString *)findPathForFile:(NSString *)fileName inBundle:(NSString *)bundleName inBundleForClass:(Class)classInBundle {
    NSBundle *bundle = [self findBundle:bundleName containingClass:classInBundle];
    if (!bundle) {
        return nil;
    }
    return [self findPathForFile:fileName inBundle:bundle];
}

+ (NSDictionary *)dictionaryForPlistFile:(NSString *)fileName inBundle:(NSString *)bundleName inBundleForClass:(Class)classInBundle {
    NSString *fullFilePath = [self findPathForFile:fileName inBundle:bundleName inBundleForClass:classInBundle];
    NSAssert(fullFilePath, @"In order to play back you need to have a plist named: %@ in a bundle called: %@ also containg this class: %@", fileName, bundleName, classInBundle);
    return [self dictionaryForPlistFilePath:fullFilePath];
}

@end
