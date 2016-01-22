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
        [self _editedScenes:dictionary[@"scenes"]];
    }
    return self;
}

- (NSMutableDictionary *)_editedScenes:(NSArray *)rawScenesArray {
    NSMutableDictionary *editedScenes = [NSMutableDictionary dictionary];
    for (NSDictionary *sceneDict in rawScenesArray) {
        
    }
    return editedScenes;
}

@end
