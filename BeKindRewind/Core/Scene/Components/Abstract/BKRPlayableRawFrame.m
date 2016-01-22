//
//  BKRPlayableRawFrame.m
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import "BKRPlayableRawFrame.h"
#import "BKRDataFrame.h"
#import "BKRResponseFrame.h"
#import "BKRRequestFrame.h"

@implementation BKRPlayableRawFrame

- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.item = dictionary;
    }
    return self;
}

- (BKRFrame *)editedFrame {
    if (![self.item isKindOfClass:[NSDictionary class]]) {
        return nil;
    } else {
        return [[NSClassFromString(self.item[@"class"]) alloc] initFromPlistDictionary:self.item];
    }
}

@end
