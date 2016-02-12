//
//  BKRRawFrame+Recordable.h
//  Pods
//
//  Created by Jordan Zucker on 2/12/16.
//
//

#import "BKRRawFrame.h"

/**
 *  This is a raw network component from a Foundation network component (NSURLRequest,
 *  NSURLResponse, NSData, NSError, etc.) that needs to be normalized into a concrete
 *  BKRFrame subclass for proper handling by the BKRRecorder instance
 */
@interface BKRRawFrame (Recordable)

- (BKRFrame *)editedRecording;

@end
