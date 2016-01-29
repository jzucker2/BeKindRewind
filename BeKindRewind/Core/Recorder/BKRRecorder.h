//
//  BKRRecorder.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

//#import "BKRCassetteHandler.h"
#import <Foundation/Foundation.h>

@class BKRRecordableCassette;
@class BKRRecordableScene;
@interface BKRRecorder : NSObject

/**
 *  Whether or not network activity should be recorded
 */
@property (nonatomic, getter=isEnabled) BOOL enabled;

@property (nonatomic, strong) BKRRecordableCassette *currentCassette;
//- (void)setCassette:(BKRRecordableCassette *)cassette;
- (NSArray<BKRRecordableScene *> *)allScenes;

/**
 *  Singleton instance is used so we don't have to pass in a
 *  reference to every disparate network connection
 *
 *  @return singleton recorder instance
 */
+ (instancetype)sharedInstance;

/**
 *  Reset all recorded values
 */
- (void)reset;

//- (void)recordTaskResumption:(NSURLSessionTask *)task;

- (void)initTask:(NSURLSessionTask *)task;

/**
 *  Called by JSZVCRNSURLSessionConnection
 *
 *  @param task in flight network task
 *  @param arg1 redirect request
 *  @param arg2 response for redirect
 */
- (void)recordTask:(NSURLSessionTask *)task redirectRequest:(NSURLRequest *)arg1 redirectResponse:(NSURLResponse *)arg2;

/**
 *  Called by JSZVCRNSURLSessionConnection
 *
 *  @param task in flight network task
 *  @param data data received from network task
 */
- (void)recordTask:(NSURLSessionTask *)task didReceiveData:(NSData *)data;

/**
 *  Called by JSZVCRNSURLSessionConnection. May be called multiple times.
 *
 *  @param task in flight network task
 *  @param response Response received from server
 */
- (void)recordTask:(NSURLSessionTask *)task didReceiveResponse:(NSURLResponse *)response;
/**
 *  Called by JSZVCRNSURLSessionConnection. Error will only
 *  be passed if something goes wrong.
 *
 *  @param task in flight network task
 *  @param arg1 error from network request
 */
- (void)recordTask:(NSString *)taskUniqueIdentifier setError:(NSError *)error;
//- (void)recordTask:(NSURLSessionTask *)task didFinishWithError:(NSError *)arg1;
/**
 *  Called by JSZVCRNSURLSessionConnection. This is called
 *  when [task cancel] is called.
 *
 *  @param task in flight network task
 */
//- (void)recordTaskCancellation:(NSURLSessionTask *)task;

///**
// *  All recordings from this instance
// *
// *  @return array of JSZVCRRecordings
// */
//- (NSArray *)allRecordings;
///**
// *  All recordings from this instance as Foundation objects,
// *  similar to NSJSONSerialization
// *
// *  @return array of Foundation objects
// */
//- (NSArray *)allRecordingsForPlist;

@end
