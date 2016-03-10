//
//  BKRPlayingContext.h
//  Pods
//
//  Created by Jordan Zucker on 3/9/16.
//
//

#import <Foundation/Foundation.h>

@class BKRScene;

// assumed to be called in thread-safe manner, no locking or queueing inside this object, no thread-safety!
@interface BKRPlayingContext : NSObject

@property (nonatomic, strong, readonly) NSArray<BKRScene *> *allScenes;

+ (instancetype)contextWithScenes:(NSArray<BKRScene *> *)scenes;
- (void)addRequest:(NSURLRequest *)request;
- (NSUInteger)countForRequest:(NSURLRequest *)request;
- (BOOL)activateScene:(BKRScene *)scene;
- (BOOL)completeScene:(BKRScene *)scene;
- (void)incrementResponseCount;
- (NSUInteger)currentResponseCount;
- (NSArray<BKRScene *> *)currentActiveScenes;
- (NSArray<BKRScene *> *)currentCompletedScenes;
- (NSArray<BKRScene *> *)currentUnstartedScenes;
- (NSDictionary<NSString *, NSNumber *> *)allRequests;

@end
