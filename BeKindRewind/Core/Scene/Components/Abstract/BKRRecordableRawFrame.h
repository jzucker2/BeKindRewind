//
//  BKRRecordableRawFrame.h
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import "BKRRawFrame.h"
#import "BKREditable.h"

/**
 *  This is a raw network component from a Foundation network component (NSURLRequest, 
 *  NSURLResponse, NSData, NSError, etc.) that needs to be normalized into a concrete 
 *  BKRFrame subclass for proper handling by the BKRRecorder instance
 */
@interface BKRRecordableRawFrame : BKRRawFrame <BKREditable>

@end
