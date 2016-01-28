//
//  BKRPlayableCassette.m
//  Pods
//
//  Created by Jordan Zucker on 1/21/16.
//
//

#import "BKRPlayableCassette.h"
#import "BKRPlayableScene.h"

@interface BKRPlayableCassette ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, BKRPlayableScene*> *scenes;
@end

@implementation BKRPlayableCassette

@synthesize scenes = _scenes;

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
    __weak typeof(self) wself = self;
    dispatch_apply(rawScenes.count, self.processingQueue, ^(size_t iteration) {
        __strong typeof(wself) sself = wself;
        NSLog(@"adding edited scene: %zu", iteration);
        BKRPlayableScene *scene = [[BKRPlayableScene alloc] initFromPlistDictionary:rawScenes[iteration]];
        [sself addSceneToScenesDictionary:scene];
    });
}

@end
