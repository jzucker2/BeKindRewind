//
//  BKRSerializer.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <Foundation/Foundation.h>

// the NO if statement doesn't run but is a compiler check to test if the object containst the key
#define JSZKey(object, selector) ({ __typeof(object) testObject = nil; if (NO) { (void)((testObject).selector); } @#selector; })

@protocol BKRSerializer <NSObject>

// guaranteed to work in plist
- (NSDictionary *)plistRepresentation;

@end
