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

- (NSMutableDictionary *)_editedScenes:(NSArray *)rawScenesArray {
    NSMutableDictionary *editedScenes = [NSMutableDictionary dictionary];
    for (NSDictionary *sceneDict in rawScenesArray) {
        BKRPlayableScene *scene = [[BKRPlayableScene alloc] initFromPlistDictionary:sceneDict];
        editedScenes[scene.uniqueIdentifier] = scene;
    }
    return editedScenes;
}

@end
