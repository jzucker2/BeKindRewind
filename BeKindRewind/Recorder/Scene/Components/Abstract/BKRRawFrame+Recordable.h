//
//  BKRRawFrame+Recordable.h
//  Pods
//
//  Created by Jordan Zucker on 2/12/16.
//
//

#import "BKRRawFrame.h"
#import "BKRConstants.h"

/**
 *  This is category to handle a raw network component from a Foundation network component (NSURLRequest,
 *  NSURLResponse, NSData, NSError, etc.) that needs to be normalized into a concrete
 *  BKRFrame subclass for proper handling by the BKRRecorder instance
 *
 *  @since 1.0.0
 */
@interface BKRRawFrame (Recordable)

/**
 *  This is a normalized version of a BKRFrame concrete subclass created from the information
 *  contained by the reciever
 *
 *  @param context helps determine the type of frame subclass to store item as
 *
 *  @return newly initialized instance of a concrete subclass of BKRFrame
 *
 *  @since 1.0.0
 */
- (BKRFrame *)editedRecordingWithContext:(BKRRecordingContext)context;

@end
