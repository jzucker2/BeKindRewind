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
 *
 *  @since 1.0.0
 */
@interface BKRVCR : NSObject <BKRVCRActions>
@end
