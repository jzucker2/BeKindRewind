//
//  BKRCassette+Playable.m
//  Pods
//
//  Created by Jordan Zucker on 2/15/16.
//
//

#import "BKRCassette+Playable.h"
#import "BKRScene+Playable.h"
#import "BKRConstants.h"

@implementation BKRCassette (Playable)

+ (instancetype)cassetteFromDictionary:(NSDictionary *)dictionary {
    return [[self alloc] initFromPlistDictionary:dictionary];
}

- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary {
    self = [[[self class] alloc] init];
    if (self) {
        self.creationDate = dictionary[@"creationDate"];
        [self _addEditedScenes:dictionary[@"scenes"]];
    }
    return self;
}

- (void)_addEditedScenes:(NSArray<NSDictionary *> *)rawScenes {
    BKRWeakify(self);
    dispatch_apply(rawScenes.count, self.processingQueue, ^(size_t iteration) {
        BKRStrongify(self);
        BKRScene *scene = [[BKRScene alloc] initFromPlistDictionary:rawScenes[iteration]];
        [self addSceneToScenesDictionary:scene];
    });
}

@end
