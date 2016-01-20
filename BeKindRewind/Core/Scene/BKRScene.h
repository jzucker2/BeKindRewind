//
//  BKRScene.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRSerializer.h"

@class BKRFrame;
@class BKRDataFrame;
@class BKRRawFrame;
@class BKRError;
@class BKRRequestFrame;
@class BKRResponseFrame;
@interface BKRScene : NSObject <BKRSerializer>

@property (nonatomic, copy, readonly) NSString *uniqueIdentifier;
@property (nonatomic, copy, readonly) BKRFrame *clapboardFrame;

- (instancetype)initFromFrame:(BKRRawFrame *)frame;
+ (instancetype)sceneFromFrame:(BKRRawFrame *)frame;
- (void)addFrame:(BKRRawFrame *)frame;
- (NSArray<BKRFrame *> *)allFrames;
- (NSArray<BKRDataFrame *> *)allDataFrames;
- (NSArray<BKRResponseFrame *> *)allResponseFrames;
- (NSArray<BKRRequestFrame *> *)allRequestFrames;
- (BKRRequestFrame *)originalRequest;
- (BKRRequestFrame *)currentRequest;


@end
