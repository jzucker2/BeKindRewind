//
//  BKRConstants.h
//  Pods
//
//  Created by Jordan Zucker on 1/20/16.
//
//

#ifndef BKRConstants_h
#define BKRConstants_h

// the NO if statement doesn't run but is a compiler check to test if the object containst the key
#define BKRKey(object, selector) ({ __typeof(object) testObject = nil; if (NO) { (void)((testObject).selector); } @#selector; })

/**
 *  Block for code execution before stubs are added for playback
 */
typedef void (^BKRBeforeAddingStubs)(void);

/**
 *  Block for code execution after stubs are added for playback
 */
typedef void (^BKRAfterAddingStubs)(void);

/**
 *  Block for execution before a NSURLSessionTask begins recording
 *
 *  @param task NSURLSessionTask that just began executing
 */
typedef void (^BKRBeginRecordingTaskBlock)(NSURLSessionTask *task);

/**
 *  Block for execution after a NSURLSessionTask ends recording
 *
 *  @param task NSURLSessionTask that just finished recording
 */
typedef void (^BKREndRecordingTaskBlock)(NSURLSessionTask *task);


#endif /* BKRConstants_h */
