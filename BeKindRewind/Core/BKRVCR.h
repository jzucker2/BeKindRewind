//
//  BKRVCR.h
//  Pods
//
//  Created by Jordan Zucker on 1/19/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRRequestMatching.h"

@class BKRCassette;

/**
 *  This is the major unit of the BeKindRewind framework. It is similar to the VCR (Video Cassette Recorder)
 *  of the 1980s. Like a VCR, it can record information to a cassette or use a cassette to 
 *  play back information. Unlike the VCR of the 1980s which records and plays back grainy 
 *  video, the BKRVCR records and plays back network activity in Objective-C and Swift.
 */
@interface BKRVCR : NSObject

/**
 *  Designated intializer for creating a BKRVCR instance. Must provide a
 *  matcherClass so that play back can occur. Once a BKRVCR instance is initialized, 
 *  the matcher created by matcherClass cannot be changed.
 *
 *
 *  @param matcherClass class must conform to BKRRequestMatching and will be 
 *                      used to construct stubs for playing back network operations. Throws 
 *                      NSInternalInconsistency exception if this is nil
 *
 *
 *  @return newly initialized instance of BKRVCR
 */
- (instancetype)initWithMatcherClass:(Class<BKRRequestMatching>)matcherClass;

/**
 *  Convenience constructor for creating a BKRVCR instance. Must provide a
 *  matcherClass so that play back can occur. Once a BKRVCR instance is initialized,
 *  the matcher created by matcherClass cannot be changed.
 *
 *  @param matcherClass class must conform to BKRRequestMatching and will be used to 
 *                      construct stubs for playing back network operations. Throws
 *                      NSInternalInconsistency exception if this is nil
 *
 *  @return newly initialized instance of BKRVCR
 */
+ (instancetype)vcrWithMatcherClass:(Class<BKRRequestMatching>)matcherClass;

/**
 *  This determines whether the BKRVCR instance is playing or recording.
 *  If recording is YES then the VCR is saving network activity information
 *  to the BKRCassette instance stored in currentCassette. If this is NO,
 *  then the VCR is playing back network operations from the BKRCassette
 *  instance stored in currentCassette.
 *  @note default is NO
 */
@property (nonatomic, getter=isRecording) BOOL recording;

/**
 *  Default is NO, when isDisabled is set to YES, recording and 
 *  playback are both turned off. This is not expected to be used often.
 */
@property (nonatomic, getter=isDisabled) BOOL disabled;



/**
 *  Recordings or stubbings for a session are contained in this object. If this
 *  property is nil then network operations are not recorded or stubbed.
 */
@property (nonatomic, strong, readonly) BKRCassette *currentCassette;

/**
 *  This is the matcher object created during class initialization. It is
 *  used internally by the internal BKRPlayer instance to create the stubs
 *  used in playing back network operations.
 */
@property (nonatomic, strong, readonly) id<BKRRequestMatching> matcher;

@end
