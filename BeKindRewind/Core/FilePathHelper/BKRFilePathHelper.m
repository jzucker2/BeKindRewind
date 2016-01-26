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
    return [self _findPathForFile:fileName inBundle:bundle];
}

+ (NSString *)_findPathForFile:(NSString *)fileName inBundle:(NSBundle *)bundle {
    return [bundle pathForResource:fileName.stringByDeletingPathExtension ofType:fileName.pathExtension];
}

+ (NSDictionary *)_dictionaryForPlistFilePath:(NSString *)filePath {
    NSParameterAssert(filePath);
    NSParameterAssert([filePath.pathExtension isEqualToString:@"plist"]);
    return [[NSDictionary alloc] initWithContentsOfFile:filePath];
}

+ (NSDictionary *)dictionaryForPlistFile:(NSString *)fileName inBundleForClass:(Class)classInBundle {
    NSString *filePath = [self findPathForFile:fileName inBundleForClass:classInBundle];
//    if (filePath) {
//        NSDictionary *dictionary = [self _dictionaryForPlistFilePath:filePath];
//        NSAssert([dictionary isKindOfClass:[NSDictionary class]], @"Plist root object must be a dictionary, not %@", dictionary.class);
//        return dictionary;
//    }
//    return nil;
    NSDictionary *dictionary = [self _dictionaryForPlistFilePath:filePath];
    NSAssert([dictionary isKindOfClass:[NSDictionary class]], @"Plist root object must be a dictionary, not %@", dictionary.class);
    return dictionary;
}

@end
