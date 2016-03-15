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
    BKRPlayingSceneStateRedirecting,
    BKRPlayingSceneStateCompleted
};

@class BKRScene;
@class BKRResponseStub;
@class BKRSceneResponseStub;

@interface BKRPlayingContextItem : NSObject

+ (instancetype)itemWithScene:(BKRScene *)scene;

@property (nonatomic, strong, readonly) BKRScene *scene;
@property (nonatomic, assign) BKRPlayingSceneState state;
@property (nonatomic, assign) NSUInteger redirectCount;
@property (nonatomic, strong, readonly) NSMutableSet<BKRResponseStub *> *responseStubs;
@property (nonatomic, strong, readonly) NSMutableSet<NSURLRequest *> *requests;

@end

// assumed to be called in thread-safe manner, no locking or queueing inside this object, no thread-safety!
@interface BKRPlayingContext : NSObject

//@property (nonatomic, strong, readonly) NSArray<BKRScene *> *allScenes;
@property (nonatomic, strong, readonly) NSArray<BKRPlayingContextItem *> *allItems;

+ (instancetype)contextWithScenes:(NSArray<BKRScene *> *)scenes;
- (void)startRequest:(NSURLRequest *)request withResponseStub:(BKRResponseStub *)responseStub;
- (void)redirectOriginalRequest:(NSURLRequest *)request withRedirectRequest:(NSURLRequest *)redirectRequest withResponseStub:(BKRResponseStub *)responseStub;
- (void)completeRequest:(NSURLRequest *)request withResponseStub:(BKRResponseStub *)responseStub error:(NSError *)error;
- (NSArray<BKRPlayingContextItem *> *)inactiveItems; // never started
- (NSArray<BKRPlayingContextItem *> *)incompleteItems; // active and redirecting items
- (NSArray<BKRPlayingContextItem *> *)activeItems; // loading but not redirecting
- (NSArray<BKRPlayingContextItem *> *)redirectingItems; // redirecting, active
- (NSArray<BKRPlayingContextItem *> *)completedItems; // done, finished
- (void)addResponseStub:(BKRResponseStub *)responseStub forRequest:(NSURLRequest *)request;
//- (void)addSceneResponseStub:(BKRSceneResponseStub *)sceneResponseStub forRequest:(NSURLRequest *)request;
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
