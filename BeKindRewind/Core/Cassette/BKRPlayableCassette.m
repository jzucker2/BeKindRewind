//
//  BKRPlayableCassette.m
//  Pods
//
//  Created by Jordan Zucker on 1/21/16.
//
//

#import "BKRPlayableCassette.h"

@implementation BKRPlayableCassette

- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary {
    self = [[[self class] alloc] init];
    if (self) {
        self.creationDate = dictionary[@"creationDate"];
    }
    return self;
}

@end
