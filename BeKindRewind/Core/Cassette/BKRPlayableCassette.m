//
//  BKRPlayableCassette.m
//  Pods
//
//  Created by Jordan Zucker on 1/21/16.
//
//

#import "BKRPlayableCassette.h"
#import "BKRScene+Playable.h"

@interface BKRPlayableCassette ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, BKRScene*> *scenes;
@end

@implementation BKRPlayableCassette

@synthesize scenes = _scenes;

+ (instancetype)cassetteFromDictionary:(NSDictionary *)dictionary {
    return [[self alloc] initFromPlistDictionary:dictionary];
}

- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary {
    self = [[[self class] alloc] init];
    if (self) {
        self.creationDate = dictionary[@"creationDate"];
        _scenes = [NSMutableDictionary dictionary];
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

- (void)executeAfterAddingStubsBlock:(BKRAfterAddingStubs)afterStubsBlock {
    dispatch_barrier_async(self.processingQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            afterStubsBlock();
        });
    });
}

@end
