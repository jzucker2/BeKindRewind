//
//  BKRError.m
//  Pods
//
//  Created by Jordan Zucker on 1/19/16.
//
//

#import "BKRError.h"

@interface BKRError ()
@property (nonatomic, copy) NSError *error;
@end

@implementation BKRError

- (void)addError:(NSError *)error {
    self.error = error;
}

@end
