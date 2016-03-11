//
//  BKRPlayingContext.h
//  Pods
//
//  Created by Jordan Zucker on 3/9/16.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BKRPlayingSceneState) {
    BKRPlayingSceneStateInactive = 0,
    BKRPlayingSceneStateActive,
    BKRPlayingSceneStateRunning,
    BKRPlayingSceneStateCompleted
};

@class BKRScene;
@class BKRResponseStub;

@interface BKRPlayingContextItem : NSObject

+ (instancetype)itemWithScene:(BKRScene *)scene;

@property (nonatomic, strong, readonly) BKRScene *scene;
@property (nonatomic, assign) BKRPlayingSceneState state;

@end

// assumed to be called in thread-safe manner, no locking or queueing inside this object, no thread-safety!
@interface BKRPlayingContext : NSObject

//@property (nonatomic, strong, readonly) NSArray<BKRScene *> *allScenes;
@property (nonatomic, strong, readonly) NSArray<BKRPlayingContextItem *> *allItems;

+ (instancetype)contextWithScenes:(NSArray<BKRScene *> *)scenes;
- (void)startRequest:(NSURLRequest *)request withResponseStub:(BKRResponseStub *)responseStub;
- (void)redirectOriginalRequest:(NSURLRequest *)request withRedirectRequest:(NSURLRequest *)redirectRequest withResponseStub:(BKRResponseStub *)responseStub;
- (void)completeRequest:(NSURLRequest *)request withResponseStub:(BKRResponseStub *)responseStub error:(NSError *)error;
//- (NSUInteger)countForRequest:(NSURLRequest *)request;
//- (BOOL)activateScene:(BKRScene *)scene;
//- (BOOL)completeScene:(BKRScene *)scene;
//- (void)incrementResponseCount;
//- (NSUInteger)currentResponseCount;
//- (NSArray<BKRScene *> *)currentActiveScenes;
//- (NSArray<BKRScene *> *)currentCompletedScenes;
//- (NSArray<BKRScene *> *)currentUnstartedScenes;
//- (NSDictionary<NSString *, NSNumber *> *)allRequests;

@end
