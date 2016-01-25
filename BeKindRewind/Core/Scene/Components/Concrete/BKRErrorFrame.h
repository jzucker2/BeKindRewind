//
//  BKRErrorFrame.h
//  Pods
//
//  Created by Jordan Zucker on 1/25/16.
//
//

#import "BKRFrame.h"
#import "BKRPlistSerializing.h"

@interface BKRErrorFrame : BKRFrame <BKRPlistSerializing>

- (void)addError:(NSError *)error;
- (NSError *)error;

@end
