//
//  BKRPlayingContext.m
//  Pods
//
//  Created by Jordan Zucker on 3/9/16.
//
//

#import "BKRPlayingContext.h"
#import "BKRScene.h"

@interface BKRPlayingContext () <NSCopying>
@property (nonatomic, strong, readwrite) NSArray<BKRScene *> *allScenes;
@property (nonatomic, strong) NSMutableSet<BKRScene *> *activeScenes;
@property (nonatomic, strong) NSMutableSet<BKRScene *> *completedScenes;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *requests;
@property (nonatomic, assign) NSUInteger responseCount;
@end

@implementation BKRPlayingContext

- (NSUInteger)currentResponseCount {
    return self.responseCount;
}

- (NSArray<BKRScene *> *)currentActiveScenes {
    return self.activeScenes.allObjects;
}

- (NSArray<BKRScene *> *)currentCompletedScenes {
    return self.completedScenes.allObjects;
}

- (NSArray<BKRScene *> *)currentUnstartedScenes {
    NSMutableSet *allScenesSet = [NSMutableSet setWithArray:self.allScenes];
    [allScenesSet minusSet:self.activeScenes.copy]; // is the copy necessary?
    [allScenesSet minusSet:self.completedScenes.copy]; // is the copy necessary?
    return allScenesSet.allObjects.scenesSortedByClapboardFrameCreationDate;
}

- (NSDictionary<NSString *, NSNumber *> *)allRequests {
    return self.requests.copy;
}

- (instancetype)initWithScenes:(NSArray<BKRScene *> *)scenes {
    self = [super init];
    if (self) {
        //        _activeScenes = [NSMutableArray array];
        //        _allScenes = [NSMutableArray array];
        //        _completedScenes = [NSMutableArray array];
        _activeScenes = [NSMutableSet set];
        //        _allScenes = [NSMutableSet set];
        _allScenes = scenes;
        _completedScenes = [NSMutableSet set];
        _requests = [NSMutableDictionary dictionary];
        _responseCount = 0;
    }
    return self;
}

+ (instancetype)contextWithScenes:(NSArray<BKRScene *> *)scenes {
    return [[self alloc] initWithScenes:scenes];
}

- (void)addRequest:(NSURLRequest *)request {
    NSString *requestURLString = request.URL.absoluteString;
    if (!requestURLString) {
        return;
    }
    if (self.requests[requestURLString]) {
        NSInteger requestCount = [self.requests[requestURLString] integerValue];
        self.requests[requestURLString] = @(++requestCount);
    } else {
        self.requests[requestURLString] = @(1);
    }
}

- (NSUInteger)countForRequest:(NSURLRequest *)request {
    NSString *requestURLString = request.URL.absoluteString;
    if (!requestURLString) {
        return 0;
    }
    if (!self.requests[requestURLString]) {
        return 0;
    }
    return [self.requests[requestURLString] unsignedIntegerValue];
}

- (BOOL)activateScene:(BKRScene *)scene {
    if ([self.activeScenes containsObject:scene]) {
        return NO;
    } else {
        [self.activeScenes addObject:scene];
        return YES;
    }
}

- (BOOL)completeScene:(BKRScene *)scene {
    [self.activeScenes removeObject:scene];
    if ([self.completedScenes containsObject:scene]) {
        return NO;
    } else {
        [self.completedScenes addObject:scene];
        return YES;
    }
}

- (void)incrementResponseCount {
    self.responseCount++;
}

- (id)copyWithZone:(NSZone *)zone {
    BKRPlayingContext *context = [[[self class] allocWithZone:zone] init];
    context.activeScenes = self.activeScenes;
    context.completedScenes = self.completedScenes;
    context.allScenes = self.allScenes;
    context.responseCount = self.responseCount;
    context.requests = self.requests;
    return context;
}

@end
