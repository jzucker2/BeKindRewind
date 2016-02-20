//
//  BKRVCRActions.h
//  Pods
//
//  Created by Jordan Zucker on 2/8/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRConstants.h"

/**
 *  This describes the state of the object conforming to BKRVCRActions. There are a range of actions, this enum is meant to be exhaustive.
 *
 */
typedef NS_ENUM(NSInteger, BKRVCRState) {
    /**
     *  Should not be here. If this happens, please file an issue on GitHub and include any and all possible information to help diagnose. The behavior of an object conforming to BKRVCRActions in this state should be undefined.
     */
    BKRVCRStateUnknown = -1,
    /**
     *  The VCR is not playing or recording and the playhead is at the beginning. This is equivalent to disabled
     */
    BKRVCRStateStopped = 0,
    /**
     *  The VCR is stubbing recordings
     */
    BKRVCRStatePlaying = 1,
    /**
     *  The VCR is saving recordings to a BKRCassette object
     */
    BKRVCRStateRecording = 2,
    /**
     *  The VCR is was recently in BKRVCRStatePlaying or BKRVCRStateRecording and just stopped briefly.
     */
    BKRVCRStatePaused = 3,
};

// what would i use this for?
typedef NS_OPTIONS(NSUInteger, BKRVCRConfiguration) {
    BKRVCRConfigurationEmpty            = 0,
    BKRVCRConfigurationHasCassette      = 1 << 0,
    BKRVCRConfigurationHasCassettePath  = 1 << 1,
    BKRVCRConfigurationIsRecording      = 1 << 2,
    BKRVCRConfigurationIsPlaying        = 1 << 3,
};

@class BKRCassette;

@protocol BKRVCRRecording <NSObject>

/**
 *  This block executes on the main queue before any network request
 *  begins. Make sure not to deadlock or execute slow code. It passes in
 *  the NSURLSessionTask associated with this recording.
 *
 *  @note this block is executed synchronously on the main queue
 */
@property (nonatomic, copy) BKRBeginRecordingTaskBlock beginRecordingBlock;

/**
 *  This block executes on the main queue after any network request
 *  begins. Make sure not to deadlock or execute slow code. It passes in
 *  the NSURLSessionTask associated with this recording.
 *
 *  @note this block is executed asynchronously on the main queue
 */
@property (nonatomic, copy) BKREndRecordingTaskBlock endRecordingBlock;

@end

typedef void (^BKRCassetteHandlingBlock)(BOOL result);
typedef BKRCassette *(^BKRVCRCassetteLoadingBlock)(void);
typedef NSString *(^BKRVCRCassetteSavingBlock)(BKRCassette *cassette);

@protocol BKRVCRActions <NSObject>

- (void)playWithCompletionBlock:(void (^)(void))completionBlock;
- (void)pauseWithCompletionBlock:(void (^)(void))completionBlock; // is there a difference between stop and pause?
- (void)stopWithCompletionBlock:(void (^)(void))completionBlock; // is there a difference between stop and pause?
- (void)resetWithCompletionBlock:(void (^)(void))completionBlock; // reset to start of cassette
- (BOOL)insert:(BKRVCRCassetteLoadingBlock)cassetteLoadingBlock completionHandler:(BKRCassetteHandlingBlock)completionBlock; // must end in .plist
/**
 *  This "ejects" the current cassette, saving the results to the location specified by filePath
 */
- (BOOL)eject:(BKRVCRCassetteSavingBlock)cassetteSavingBlock completionHandler:(BKRCassetteHandlingBlock)completionBlock; // consider making BOOLEAN with something like force, etc, returns success or failure

/**
 *  Record network
 */
- (void)recordWithCompletionBlock:(void (^)(void))completionBlock;

///**
// *  Recordings or stubbings for a session are contained in this object. If this
// *  property is nil then network operations are not recorded or stubbed.
// */
@property (nonatomic, strong, readonly) BKRCassette *currentCassette;

@property (nonatomic, assign, readonly) BKRVCRState state;

//@property (nonatomic, copy, readonly) NSString *cassetteFilePath;

///**
// *  Block is executed on the main thread before all stubs for a
// *  playback session are added
// *  @note make sure not to deadlock or execute slow code in this block
// */
//@property (nonatomic, copy) BKRBeforeAddingStubs beforeAddingStubsBlock;
//
///**
// *  Block is executed on the main thread after all stubs for a
// *  playback session are added
// *  @note make sure not to deadlock or execute slow code in this block
// */
//@property (nonatomic, copy) BKRAfterAddingStubs afterAddingStubsBlock;
//
///**
// *  This block executes on the main queue before any network request
// *  begins. Make sure not to deadlock or execute slow code. It passes in
// *  the NSURLSessionTask associated with this recording.
// *
// *  @note this block is executed synchronously on the main queue
// */
//@property (nonatomic, copy) BKRBeginRecordingTaskBlock beginRecordingBlock;
//
///**
// *  This block executes on the main queue after any network request
// *  begins. Make sure not to deadlock or execute slow code. It passes in
// *  the NSURLSessionTask associated with this recording.
// *
// *  @note this block is executed asynchronously on the main queue
// */
//@property (nonatomic, copy) BKREndRecordingTaskBlock endRecordingBlock;

//- (NSInteger)playhead;
//- (NSInteger)totalRequests;


@end
