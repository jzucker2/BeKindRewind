//
//  BKRVCRActions.h
//  Pods
//
//  Created by Jordan Zucker on 2/8/16.
//
//

#import <Foundation/Foundation.h>

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

@class BKRCassette;

@protocol BKRVCRActions <NSObject>

- (void)play;
- (void)pause; // is there a difference between stop and pause?
- (void)stop; // is there a difference between stop and pause?
- (void)reset; // reset to start of cassette
- (void)insert:(NSString *)cassetteFilePath; // must end in .plist
/**
 *  This "ejects" the current cassette, saving the results to the location specified by filePath
 */
- (BOOL)eject:(BOOL)shouldOverwrite; // consider making BOOLEAN with something like force, etc, returns success or failure

/**
 *  Record network
 */
- (void)record;

///**
// *  Recordings or stubbings for a session are contained in this object. If this
// *  property is nil then network operations are not recorded or stubbed.
// */
//@property (nonatomic, strong, readonly) BKRCassette *currentCassette;

@property (nonatomic, assign, readonly) BKRVCRState state;

@property (nonatomic, copy, readonly) NSString *cassetteFilePath;

//- (NSInteger)playhead;
//- (NSInteger)totalRequests;


@end
