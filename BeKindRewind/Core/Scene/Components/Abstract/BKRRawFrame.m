//
//  BKRRawFrame.m
//  Pods
//
//  Created by Jordan Zucker on 1/20/16.
//
//

#import "BKRRawFrame.h"

@implementation BKRRawFrame

- (NSString *)debugDescription {
    NSString *superDebugDescription = [super debugDescription];
    NSString *additionalDebugDescription = [NSString stringWithFormat:@"item class: %@", [self.item class]];
    return [NSString stringWithFormat:@"%@, %@", superDebugDescription, additionalDebugDescription];
}

@end
