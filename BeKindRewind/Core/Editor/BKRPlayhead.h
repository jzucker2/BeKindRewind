//
//  BKRPlayhead.h
//  Pods
//
//  Created by Jordan Zucker on 3/15/16.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BKRPlayingSceneState) {
    BKRPlayingSceneStateInactive = 0,
    BKRPlayingSceneStateActive,
    BKRPlayingSceneStateCompleted
};

@class BKRScene;
@class BKRResponseStub;

@interface BKRPlayheadItem : NSObject

+ (instancetype)itemWithScene:(BKRScene *)scene;

@property (nonatomic, strong, readonly) BKRScene *scene;
@property (nonatomic, assign) BKRPlayingSceneState state;
@property (nonatomic, assign, readonly) NSUInteger expectedNumberOfRedirects;
@property (nonatomic, assign) NSUInteger redirectsCompleted;
@property (nonatomic, strong, readonly) NSMutableArray<BKRResponseStub *> *responseStubs;
@property (nonatomic, strong, readonly) NSMutableArray<NSURLRequest *> *requests;

@end

// assumed to be called in thread-safe manner, no locking or queueing inside this object, no thread-safety!
@interface BKRPlayhead : NSObject

@property (nonatomic, strong, readonly) NSArray<BKRPlayheadItem *> *allItems;

+ (instancetype)playheadWithScenes:(NSArray<BKRScene *> *)scenes;
- (void)startRequest:(NSURLRequest *)request withResponseStub:(BKRResponseStub *)responseStub;
- (void)redirectOriginalRequest:(NSURLRequest *)request withRedirectRequest:(NSURLRequest *)redirectRequest withResponseStub:(BKRResponseStub *)responseStub;
- (void)completeRequest:(NSURLRequest *)request withResponseStub:(BKRResponseStub *)responseStub error:(NSError *)error;
- (NSArray<BKRPlayheadItem *> *)inactiveItems; // never started
- (NSArray<BKRPlayheadItem *> *)incompleteItems; // inactive and active items
- (NSArray<BKRPlayheadItem *> *)activeItems; // active and/or redirecting (does not include items that haven't started or already finished)
- (NSArray<BKRPlayheadItem *> *)redirectingItems; // redirecting, active
- (NSArray<BKRPlayheadItem *> *)completedItems; // done, finished
- (void)addResponseStub:(BKRResponseStub *)responseStub forRequest:(NSURLRequest *)request;

@end
