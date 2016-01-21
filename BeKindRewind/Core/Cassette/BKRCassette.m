//
//  BKRCassette.m
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import "BKRCassette.h"
#import "BKRScene.h"
#import "BKRFrame.h"
#import "BKRConstants.h"

@interface BKRCassette ()
@end

@implementation BKRCassette

- (instancetype)init {
    self = [super init];
    if (self) {
        _creationDate = [NSDate date];
        _scenes = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSArray<BKRScene *> *)allScenes {
// TODO: check if this orders properly, possibly with a test
    return [self.scenes.allValues sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:BKRKey(BKRScene *, clapboardFrame.creationDate) ascending:YES]]];
}

//- (NSDictionary *)plistDictionary {
//    NSMutableArray *plistArray = [NSMutableArray array];
//    for (BKRScene *scene in self.allScenes) {
//        [plistArray addObject:scene.plistDictionary];
//    }
//    NSMutableDictionary *plistDict = [@{
//                                        @"scenes": [[NSArray alloc] initWithArray:plistArray copyItems:YES]
//                                        } mutableCopy];
//    plistDict[@"creationDate"] = self.creationDate.copy;
//    return [[NSDictionary alloc] initWithDictionary:plistDict copyItems:YES];
//}
//
//- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary {
//    self = [super init];
//    if (self) {
//        
//    }
//    return self;
//}

@end
