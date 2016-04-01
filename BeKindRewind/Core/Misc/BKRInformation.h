//
//  BKRInformation.h
//  Pods
//
//  Created by Jordan Zucker on 2/24/16.
//
//

#import <Foundation/Foundation.h>

/**
 *  This object represents metadata associated with the BeKindRewind framework
 */
@interface BKRInformation : NSObject

/**
 *  Fetches the version string from the framework's Info.plist
 *
 *  @return string representing the version (semantic versioning) 
 */
+ (NSString *)version;

@end
