//
//  BKRVCRActions.h
//  Pods
//
//  Created by Jordan Zucker on 2/8/16.
//
//

#import <Foundation/Foundation.h>

@protocol BKRVCRActions <NSObject>

- (void)play;
- (void)pause;
- (void)stop;
- (void)reset; // reset to start of cassette
- (void)insertCassette:(NSString *)filePath;
/**
 *  This "ejects" the current cassette, saving the results to the location specified by filePath
 */
- (void)eject; // consider making BOOLEAN with something like force, etc

/**
 *  Record network
 */
- (void)record;

@property (nonatomic, assign, getter=isRecording) BOOL recording;

@end
