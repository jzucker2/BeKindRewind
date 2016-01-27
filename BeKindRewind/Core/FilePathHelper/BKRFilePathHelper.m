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

+ (NSBundle *)_podResourceBundle {
    NSBundle *bundle = [NSBundle bundleForClass:self];
    NSString *bundlePath = [bundle pathForResource:@"BeKindRewind" ofType:@"bundle"];
    return [NSBundle bundleWithPath:bundlePath];
}

+ (NSString *)_podProjectPlistFilePath {
    return [[self _podResourceBundle] pathForResource:@"BeKindRewind" ofType:@"plist"];
}

+ (NSDictionary *)_podProjectPlistDictionary {
    return [[NSDictionary alloc] initWithContentsOfFile:[self _podProjectPlistFilePath]];
}

+ (NSString *)fixtureWriteDirectoryInProject {
    NSDictionary *podPlist = [self _podProjectPlistDictionary];
    NSAssert(podPlist, @"Something went wrong fetching the pod plist from the resource bundle");
    if (!podPlist) {
        return @"~/Desktop/Runs/";
    }
    return podPlist[@"fixture_path"];
}

+ (BOOL)writeDictionary:(NSDictionary *)dictionary toFile:(NSString *)filePath {
    NSParameterAssert(filePath);
    NSParameterAssert([filePath.pathExtension isEqualToString:@"plist"]);
    NSParameterAssert(dictionary);
    return [dictionary writeToFile:filePath atomically:YES];
}

+ (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    return documentsPath;
}

+ (NSBundle *)writingBundleNamed:(NSString *)bundleName inDirectory:(NSString *)filePath {
    NSParameterAssert(bundleName);
    NSParameterAssert(![bundleName.pathExtension isEqualToString:@"bundle"]);
    NSString *bundlePath = [filePath stringByAppendingPathComponent:[bundleName stringByAppendingPathExtension:@"bundle"]];
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:bundlePath isDirectory:&isDir]) {
        NSError *bundleCreationError = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:bundlePath withIntermediateDirectories:YES attributes:nil error:&bundleCreationError];
        NSAssert(!bundleCreationError, @"Bundle creation failed: %@", bundleCreationError.localizedDescription);
        if (bundleCreationError) {
            NSLog(@"Bundle creation failed: %@", bundleCreationError.localizedDescription);
        }
    }
    return [NSBundle bundleWithPath:bundlePath];
}

@end
