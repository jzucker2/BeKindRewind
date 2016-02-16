//
//  BKRRawFrame+Playable.m
//  Pods
//
//  Created by Jordan Zucker on 2/12/16.
//
//

#import "BKRRawFrame+Playable.h"

@implementation BKRRawFrame (Playable)

- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.item = dictionary;
    }
    return self;
}

- (BKRFrame *)editedPlaying {
    // right now we only know how to handle dictionaries
    if (![self.item isKindOfClass:[NSDictionary class]]) {
        return nil;
    } else {
        return [[NSClassFromString(self.item[@"class"]) alloc] initFromPlistDictionary:self.item];
    }
}


@end
