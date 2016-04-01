//
//  BKRVCRActions.h
//  Pods
//
//  Created by Jordan Zucker on 2/8/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRConstants.h"
#import "BKRRequestMatching.h"

/**
 *  This describes the state of the object conforming to BKRVCRActions. There
 *  are a range of actions, this enum is meant to be exhaustive.
 *
 *  @since 1.0.0
 */
typedef NS_ENUM(NSInteger, BKRVCRState) {
    /**
     *  Should not be here. If this happens, please file an issue on GitHub 
     *  and include any and all possible information to help diagnose. The 
     *  behavior of an object conforming to BKRVCRActions in this state 
     *  should be undefined.
     *
     *  @since 1.0.0
     */
    BKRVCRStateUnknown = -1,
    /**
     *  The VCR is not playing or recording and the playhead is at 
     *  the beginning. This is equivalent to disabled
     *
     *  @since 1.0.0
     */
    BKRVCRStateStopped = 0,
    /**
     *  The VCR is stubbing recordings
     *
     *  @since 1.0.0
     */
    BKRVCRStatePlaying = 1,
    /**
     *  The VCR is saving recordings to a BKRCassette object
     *
     *  @since 1.0.0
     */
    BKRVCRStateRecording = 2,
    /**
     *  The VCR is was recently in BKRVCRStatePlaying or BKRVCRStateRecording 
     *  and just stopped briefly.
     *
     *  @since 1.0.0
     */
    BKRVCRStatePaused = 3,
};

@class BKRCassette;
@class BKRConfiguration;

/**
 *  This is the protocol used for any object expected to run blocks at the 
 *  beginning or end of any network event being recorded.
 *
 *  @since 1.0.0
 */
@protocol BKRVCRRecording <NSObject>

/**
 *  This block executes on the main queue before any network request
 *  begins. Make sure not to deadlock or execute slow code. It passes in
 *  the NSURLSessionTask associated with this recording.
 *
 *  @note this block is executed synchronously on the main queue. Make sure
 *        to not block the main queue
 *
 *  @since 1.0.0
 */
@property (nonatomic, copy) BKRBeginRecordingTaskBlock beginRecordingBlock;

/**
 *  This block executes on the main queue after any network request
 *  begins. Make sure not to deadlock or execute slow code. It passes in
 *  the NSURLSessionTask associated with this recording.
 *
 *  @note this block is executed asynchronously on the main queue
 *
 *  @since 1.0.0
 */
@property (nonatomic, copy) BKREndRecordingTaskBlock endRecordingBlock;

@end

/**
 *  This is a completion block that runs at the end 
 *  of `eject:` or `insert:` VCR commands
 *
 *  @param result result of executing command that block runs after
 *
 *  @since 1.0.0
 */
typedef void (^BKRCassetteHandlingBlock)(BOOL result);

/**
 *  This block is run by the `insert:` command to load a BKRCassette
 *  into an object conforming to this protocol
 *
 *  @return a BKRCassette instance to load into a VCR for recording or playing
 *
 *  @since 1.0.0
 */
typedef BKRCassette *(^BKRVCRCassetteLoadingBlock)(void);

/**
 *  This block is run by the `eject:` command to remove a BKRCassette
 *  from an object conforming to this protocol.
 *
 *  @param cassette the instance of BKRCassette containings recorded network events to save
 *
 *  @return full path to write recorded network events to
 *
 *  @since 1.0.0
 */
typedef NSString *(^BKRVCRCassetteSavingBlock)(BKRCassette *cassette);

/**
 *  This block is run as a completion block after almost all VCR actions
 *
 *  @param result whether or not operation is successful
 *
 *  @since 1.0.0
 */
typedef void (^BKRVCRActionCompletionBlock)(BOOL result);

/**
 *  This protocol defines the actions a VCR in the BeKindRewind framework is expected to implement.
 *  All VCR objects in this framework conform to this protocol.
 *
 *  @since 1.0.0
 */
@protocol BKRVCRActions <NSObject>

/**
 *  Designated initializer for creating an instance of an object conforming to this protocol.
 *
 *  @param configuration contains all the options to be utilized by a VCR object
 *
 *  @return newly initialized instance conforming to this protocol
 *
 *  @since 1.0.0
 */
- (instancetype)initWithConfiguration:(BKRConfiguration *)configuration;

/**
 *  Convenience initializer for creating an instance of an object conforming to this protocol.
 *
 *  @param configuration contains all the options to be utilized by a VCR object
 *
 *  @return newly initialized instance conforming to this protocol
 *
 *  @since 1.0.0
 */
+ (instancetype)vcrWithConfiguration:(BKRConfiguration *)configuration;

/**
 *  Initializes an object using `[BKRConfiguration defaultConfiguration]`
 *
 *  @return newly initialized instance conforming to this protocol
 *
 *  @since 1.0.0
 */
+ (instancetype)defaultVCR;

/**
 *  This begins playing back the network activity as stubs.
 *
 *  @param completionBlock this should be expected to be thread-safe and
 *                         called on the same queue as the receiver.
 *
 *  @since 1.0.0
 */
- (void)playWithCompletionBlock:(BKRVCRActionCompletionBlock)completionBlock;

/**
 *  This disables the receiver if it is BKRVCRStateRecording or BKRVCRStatePlaying 
 *  but will not allow the object to switch from one of the aforementioned modes 
 *  to the other. This is more a temporary disable.
 *
 *  @param completionBlock this should be expected to be thread-safe and
 *                         called on the same queue as the receiver.
 *
 *  @since 1.0.0
 */
- (void)pauseWithCompletionBlock:(BKRVCRActionCompletionBlock)completionBlock; // is there a difference between stop and pause?

/**
 *  Stop the activity, whether recording or playing back. This is a no-op if 
 *  the receiver's state is BKRVCRStateStopped. This is equivalent to 
 *  disabling both recording and playing.
 *
 *  @param completionBlock this should be expected to be thread-safe and
 *                         called on the same queue as the receiver.
 *
 *  @since 1.0.0
 */
- (void)stopWithCompletionBlock:(BKRVCRActionCompletionBlock)completionBlock; // is there a difference between stop and pause?

/**
 *  Reset the receiver, including ejecting the BKRCassette instance contained.
 *  This method is expected to be thread-safe and non-blocking
 *
 *  @param completionBlock this should be expected to be thread-safe and
 *                         called on the same queue as the receiver.
 */
- (void)resetWithCompletionBlock:(BKRVCRActionCompletionBlock)completionBlock; // reset to start of cassette

/**
 *  Record network activity. This method is expected to be thread-safe and non-blocking
 *
 *  @param completionBlock this should be expected to be thread-safe and 
 *                         called on the same queue as the receiver.
 */
- (void)recordWithCompletionBlock:(BKRVCRActionCompletionBlock)completionBlock;

/**
 *  This "inserts" the current cassette, allowing the receiver to play back or record network
 *  activity.
 *
 *  @note the file to insert must be a Property List with a file extension of ".plist".
 *
 *  @param cassetteLoadingBlock this is expected to execute in the receiver's queue
 *  @param completionBlock      this is expecte to execute in the receiver's queue
 *
 *  @return result of operation, YES indicating success and NO indicating failure
 *
 *  @since 1.0.0
 */
- (BOOL)insert:(BKRVCRCassetteLoadingBlock)cassetteLoadingBlock completionHandler:(BKRCassetteHandlingBlock)completionBlock;

/**
 *  This "ejects" the current cassette, saving the results to the location specified by filePath
 *  activity.
 *
 *  @param cassetteSavingBlock this is expected to execute in the receiver's queue
 *  @param completionBlock      this is expecte to execute in the receiver's queue
 *
 *  @return result of operation, YES indicating success and NO indicating failure
 *
 *  @since 1.0.0
 */
- (BOOL)eject:(BKRVCRCassetteSavingBlock)cassetteSavingBlock completionHandler:(BKRCassetteHandlingBlock)completionBlock;

/**
 *  Recordings or stubbings for a session are contained in this object. If this
 *  property is nil then network operations are not recorded or stubbed.
 *
 *  @since 1.0.0
 */
@property (nonatomic, strong, readonly) BKRCassette *currentCassette;

/**
 *  This is the current state of the object conforming to this protocol. Make sure state
 *  is accessed in a thread-safe manner
 *
 *  @since 1.0.0
 */
@property (nonatomic, assign, readonly) BKRVCRState state;

/**
 *  Retrieve reference on current client's configuration.
 *
 *  @return Currently used configuration instance copy. Changes to this instance won't affect
 *  receiver's configuration.
 *
 *  @since 1.0.0
 */
- (BKRConfiguration *)currentConfiguration;

@optional

/**
 *  This is the matcher object created during class initialization. It is
 *  intended to be used by the internal BKRPlayer instance to create the stubs
 *  used in playing back network operations.
 *
 *  @since 1.0.0
 */
@property (nonatomic, strong, readonly) id<BKRRequestMatching> matcher;

@end
