//
//  BKRInformation.m
//  Pods
//
//  Created by Jordan Zucker on 2/24/16.
//
//

#import "BKRInformation.h"

@implementation BKRInformation

+ (NSString *)version {
    return [[NSBundle bundleForClass:self.class] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

@end
