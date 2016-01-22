//
//  BKRPlayableScene.m
//  Pods
//
//  Created by Jordan Zucker on 1/21/16.
//
//

#import "BKRPlayableScene.h"
#import "BKRRawFrame.h"

@implementation BKRPlayableScene

- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary {
    NSParameterAssert(dictionary);
    self = [super init];
    if (self) {
        self.uniqueIdentifier = dictionary[@"uniqueIdentifier"];
        self.frames = [self _editedFrames:dictionary[@"frames"]];
    }
    return self;
}

- (NSArray<BKRFrame *> *)_editedFrames:(NSArray *)rawFrames {
    NSMutableArray <BKRFrame *> *editedFrames = [NSMutableArray array];
    for (NSDictionary *rawFrameDict in rawFrames) {
    }
    return editedFrames;
}

@end
