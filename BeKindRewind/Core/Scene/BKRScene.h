//
//  BKRScene.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <Foundation/Foundation.h>

@class BKRFrame;
@class BKRDataFrame;
@class BKRErrorFrame;
@class BKRRequestFrame;
@class BKROriginalRequestFrame;
@class BKRCurrentRequestFrame;
@class BKRRedirectFrame;
@class BKRResponseFrame;

/**
 *  This class represents all the information associated with a network request,
 *  similar to NSURLSessionTask and its subclasses. A scene typically consists of many 
 *  instances of a BKRFrame object. A typical NSURLSessionTask object will have the following
 *  components:
 *      * BKRRequestFrame representing the task.originalRequest NSURLRequest
 *      * BKRRequestFrame representing the task.currentRequest NSURLRequest (this is different in the event that the server updates the request, as per Apple's documentation (https://developer.apple.com/library/mac/documentation/Foundation/Reference/NSURLSessionTask_class/#//apple_ref/occ/instp/NSURLSessionTask/currentRequest)
 *      * BKRResponseFrame representing the NSURLResponse (or NSHTTPURLResponse) object from the server for this task
 *      * BKRDataFrame representing the data received from the server in response to the network call
 *      * BKRErrorFrame will be present if an NSError is received during the course of the network operation
 */
@interface BKRScene : NSObject

/**
 *  Unique identifier created by BeKindRewind for grouping network information into a scene
 */
@property (nonatomic, copy) NSString *uniqueIdentifier;

/**
 *  The clapboard frame is the first frame recorded in the scene, similar to a clapboard
 *  at the start of scene in a movie.
 */
@property (nonatomic, strong, readonly) BKRFrame *clapboardFrame;

/**
 *  Safely adds edited frame to the scene
 *
 *  @param frame edited frame containing a component of a network request
 */
- (void)addFrameToFramesArray:(BKRFrame *)frame;

/**
 *  Ordered (by creation date) array of all frames in scene
 *
 *  @return ordered array of BKRFrame objects
 */
- (NSArray<BKRFrame *> *)allFrames;

/**
 *  Ordered (by creation date) array of only data frames in scene
 *
 *  @return ordered array of BKRDataFrame objects
 */
- (NSArray<BKRDataFrame *> *)allDataFrames;

/**
 *  Ordered (by creation date) array of only response frames in scene
 *
 *  @return ordered array of BKRResponseFrame objects
 */
- (NSArray<BKRResponseFrame *> *)allResponseFrames;

/**
 *  Ordered (by creation date) array of only request frames in scene
 *
 *  @return ordered array of BKRRequestFrame objects
 */
- (NSArray<BKRRequestFrame *> *)allRequestFrames;

- (NSArray<BKRRedirectFrame *> *)allRedirectFrames;

- (NSArray<BKRCurrentRequestFrame *> *)allCurrentRequestFrames;

/**
 *  Ordered (by creation date) array of only error frames in scene
 *
 *  @return ordered array of BKRErrorFrame objects
 */
- (NSArray<BKRErrorFrame *> *)allErrorFrames;

/**
 *  Original request used to initiate a network request
 *
 *  @return frame containing information related to a NSURLRequest
 */
- (BKROriginalRequestFrame *)originalRequest;

/**
 *  Current request for a network request (in case the server modifies the request, as can happen with a NSURLSessionTask).
 *
 *  @return frame containing information related to a NSURLRequest
 */
- (BKRCurrentRequestFrame *)currentRequest;


@end
