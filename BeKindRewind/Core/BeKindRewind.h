//
//  BeKindRewind.h
//  Pods
//
//  Created by Jordan Zucker on 2/28/16.
//
//

#ifndef BeKindRewind_h
#define BeKindRewind_h

// Constants
#import "BKRConstants.h"

// Scene information
#import "BKRScene.h"
#import "BKRScene+Playable.h"

// Frame information
#import "BKRDataFrame.h"
#import "BKRErrorFrame.h"
#import "BKRRequestFrame.h"
#import "BKRResponseFrame.h"
#import "BKRRedirectFrame.h"

// Request Matching Protocol
#import "BKRRequestMatching.h"

// Request Matchers
#import "BKRAnyMatcher.h"
#import "BKRPlayheadMatcher.h"

//  This is used by the framework to uniquefy
//  network tasks. Helpful to for developers.
#import "NSURLSessionTask+BKRAdditions.h"

// Shouldn't need to import recordable yet
#import "BKRCassette.h"
#import "BKRCassette+Playable.h"

// Configuration
#import "BKRConfiguration.h"

// File Path Helper
#import "BKRFilePathHelper.h"

// VCR protocol
#import "BKRVCRActions.h"

// VCR
#import "BKRVCR.h"

// VCR Subclasses
#import "BKRPlayableVCR.h"
#import "BKRRecordableVCR.h"

// XCTestCase
#import "NSURLSessionTask+BKRTestAdditions.h"
#import "BKRTestCaseFilePathHelper.h"
#import "BKRTestConfiguration.h"
#import "BKRTestVCRActions.h"
#import "BKRTestVCR.h"
#import "BKRTesting.h"
#import "BKRTestCase.h"

#endif /* BeKindRewind_h */
