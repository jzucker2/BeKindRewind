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
@property (nonatomic, strong) NSDictionary<NSString *, BKRPlayableScene*> *scenes;
@end

@implementation BKRPlayableCassette

@synthesize scenes = _scenes;

- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary {
    self = [[[self class] alloc] init];
    if (self) {
        self.creationDate = dictionary[@"creationDate"];
        _scenes = [self _editedScenes:dictionary[@"scenes"]];
    }
    return self;
}

- (NSDictionary *)_editedScenes:(NSArray<NSDictionary *> *)rawScenes {
    __block NSMutableDictionary *editedScenes = [NSMutableDictionary dictionary];
    dispatch_apply(rawScenes.count, self.processingQueue, ^(size_t iteration) {
        NSLog(@"adding edited scene: %zu", iteration);
        BKRPlayableScene *scene = [[BKRPlayableScene alloc] initFromPlistDictionary:rawScenes[iteration]];
        editedScenes[scene.uniqueIdentifier] = scene;
    });
    
    NSLog(@"finished adding edited scenes");
    return editedScenes.copy;
}

@end
