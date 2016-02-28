//
//  BKRVCR.h
//  Pods
//
//  Created by Jordan Zucker on 1/19/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRRequestMatching.h"
#import "BKRVCRActions.h"

/**
 *  This is the major unit of the BeKindRewind framework. It is similar to the VCR (Video Cassette Recorder)
 *  of the 1980s. Like a VCR, it can record information to a cassette or use a cassette to 
 *  play back information. Unlike the VCR of the 1980s which records and plays back grainy 
 *  video, the BKRVCR records and plays back network activity in Objective-C and Swift.
 */
@interface BKRVCR : NSObject <BKRVCRActions>

/**
 *  This is the matcher object created during class initialization. It is
 *  used internally by the internal BKRPlayer instance to create the stubs
 *  used in playing back network operations.
 */
@property (nonatomic, strong, readonly) id<BKRRequestMatching> matcher;

@end
