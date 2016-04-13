//
//  BKRPlayhead.h
//  Pods
//
//  Created by Jordan Zucker on 3/15/16.
//
//

#import <Foundation/Foundation.h>

/**
 *  This is the possible states that a BKRScene being played can be in.
 *
 *  @since 1.0.0
 */
typedef NS_ENUM(NSInteger, BKRPlayingSceneState) {
    /**
     *  This state represents a scene that has not started.
     *
     *  @since 1.0.0
     */
    BKRPlayingSceneStateInactive = 0,
    /**
     *  This state represents a scene that has started but not finished.
     *
     *  @since 1.0.0
     */
    BKRPlayingSceneStateActive,
    /**
     *  This state represents a scene that finished execution.
     *
     *  @since 1.0.0
     */
    BKRPlayingSceneStateCompleted
};

/**
 *  This key is used to access the BKRResponseStub instance
 *  returned for a scene
 *
 *  @since 2.0.0
 */
extern const NSString *kBKRReturnedResponseStubKey;

/**
 *  This key is used to access the NSURLRequest that was
 *  matched by BeKindRewind
 *
 *  @since 2.0.0
 */
extern const NSString *kBKRReturnedRequestKey;

@class BKRScene;
@class BKRResponseStub;

/**
 *  This is object represents an network action that was mocked by BeKindRewind during a playing session.
 *
 *  @since 1.0.0
 */
@interface BKRPlayheadItem : NSObject

/**
 *  Convenience initializer for BKRPlayheadItem representing a BKRScene instance
 *
 *  @param scene this is the BKRScene instance to mock and track
 *
 *  @return newly initialized instance of BKRPlayheadItem
 *
 *  @since 1.0.0
 */
+ (instancetype)itemWithScene:(BKRScene *)scene;

/**
 *  This is the BKRScene that is represented by the receiver
 *
 *  @since 1.0.0
 */
@property (nonatomic, strong, readonly) BKRScene *scene;

/**
 *  This is the current state of scene
 *
 *  @since 1.0.0
 */
@property (nonatomic, assign) BKRPlayingSceneState state;

/**
 *  This number is how many redirects the receiver expects to encounter
 *
 *  @since 1.0.0
 */
@property (nonatomic, assign, readonly) NSUInteger expectedNumberOfRedirects;

/**
 *  This number is how many redirects the receiver has encountered.
 *
 *  @since 1.0.0
 */
@property (nonatomic, assign) NSUInteger redirectsCompleted;

/**
 *  This is the request and response stub returned for each item.
 *
 *  @since 2.0.0
 */
@property (nonatomic, strong, readonly) NSMutableArray<NSDictionary *> *returnedResponses;

/**
 *  Convenience method that checks if the receiver has returned a final response stub.
 *
 *  @return If `YES` then the receiver has returned a final response stub. If `NO`
 *          then the receiver is either redirecting or has not started.
 *
 *  @since 1.0.0
 */
- (BOOL)hasFinalResponseStub;

/**
 *  This is the number of redirects that have been stubbed by the receiver
 *
 *  @return a NSUInteger value
 *
 *  @since 1.0.0
 */
- (NSUInteger)numberOfRedirectsStubbed;

/**
 *  This method determines whether the receiver expects to redirect again
 *
 *  @return If `YES` then the receiver has more redirects that have not been 
 *          stubbed. If `NO` then the receiver redirected a request for every
 *          expected redirect.
 *
 *  @since 1.0.0
 */
- (BOOL)expectsRedirect;

@end

/**
 *  This is used by BeKindRewind to collect information about what has and is being
 *  mocked by during a playing session. This is assumed to be called in a thread-safe
 *  manner but is not itself thread-safe in any way. There should be no locking or 
 *  queuing within this object so that it does not delay the queue it is called in.
 *
 *  @since 1.0.0
 */
@interface BKRPlayhead : NSObject

/**
 *  This array contains all the BKRPlayheadItem objects tracked by the receiver.
 *
 *  @since 1.0.0
 */
@property (nonatomic, strong, readonly) NSArray<BKRPlayheadItem *> *allItems;

/**
 *  Convenience initializer to create a BKRPlayhead instance from an array of BKRScene instances.
 *
 *  @param scenes array of BKRScene instances to track
 *
 *  @return newly initialized instance of BKRPlayhead
 *
 *  @since 1.0.0
 */
+ (instancetype)playheadWithScenes:(NSArray<BKRScene *> *)scenes;

/**
 *  Update playhead with a request and responseStub that just started
 *
 *  @param request      this is a NSURLRequest instance that is beginning to be mocked
 *  @param responseStub this is the stub that was used to mock request
 *
 *  @since 1.0.0
 */
- (void)startRequest:(NSURLRequest *)request withResponseStub:(BKRResponseStub *)responseStub;

/**
 *  Update playhead with a request and responseStub that was just redirected
 *
 *  @param request         this is a NSURLRequest instance that is being redirected
 *  @param redirectRequest this is a NSURLRequest instance that will be the redirect for request
 *  @param responseStub    this is the stub that was used to redirect the request
 *
 *  @since 1.0.0
 */
- (void)redirectOriginalRequest:(NSURLRequest *)request withRedirectRequest:(NSURLRequest *)redirectRequest withResponseStub:(BKRResponseStub *)responseStub;

/**
 *  Update playhead with a request and responseStub that was just completed
 *
 *  @param request      this is a NSURLRequest instance that is finishing execution
 *  @param responseStub this is the stub that was used to redirect the request
 *  @param error        this is the error (if any) that was returned as part of the
 *                      response, or if something went wrong with a framework unrelated to the stub.
 *
 *  @since 1.0.0
 */
- (void)completeRequest:(NSURLRequest *)request withResponseStub:(BKRResponseStub *)responseStub error:(NSError *)error;

/**
 *  This records a BKRResponseStub instance and NSURLRequest instance after it has been stubbed.
 *
 *  @param responseStub This is the stub that was just used
 *  @param request      This is the request that was just mocked.
 *
 *  @since 1.0.0
 */
- (void)addResponseStub:(BKRResponseStub *)responseStub forRequest:(NSURLRequest *)request;

/**
 *  This is filters allItems to include only BKRPlayheadItem instances that have not started.
 *
 *  @return array of BKRPlayheadItem instances with state BKRPlayingSceneStateInactive
 *
 *  @since 1.0.0
 */
- (NSArray<BKRPlayheadItem *> *)inactiveItems;

/**
 *  This filters allItems to include only BKRPlayheadItem instances that have not 
 *  finished (either started or not started).
 *
 *  @return array of BKRPlayheadItem instances that has state not equal to BKRPlayingSceneStateActive
 *
 *  @since 1.0.0
 */
- (NSArray<BKRPlayheadItem *> *)incompleteItems;

/**
 *  This filters allItems to include only BKRPlayheadItem instances that have started
 *  (included those that are redirecting).
 *
 *  @return array of BKRPlayheadItem instances with state BKRPlayingSceneStateActive
 *
 *  @since 1.0.0
 */
- (NSArray<BKRPlayheadItem *> *)activeItems;

/**
 *  This filters allItems to include only BKRPlayheadItem instances that are currently redirecting.
 *
 *  @return array of BKRPlayheadItem instances that are currently redirecting
 *
 *  @since 1.0.0
 */
- (NSArray<BKRPlayheadItem *> *)redirectingItems;

/**
 *  This filters allItems to include only BKRPlayheadItem instances that have started and finished.
 *
 *  @return array of BKRPlayheadItem instances with state BKRPlayingSceneStateCompleted
 *
 *  @since 1.0.0
 */
- (NSArray<BKRPlayheadItem *> *)completedItems;

@end
