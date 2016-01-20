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
@class BKRError;
@class BKRRequest;
@class BKRResponse;
@interface BKRScene : NSObject <BKRSerializer>

@property (nonatomic, copy, readonly) NSString *uniqueIdentifier;
@property (nonatomic, copy, readonly) BKRFrame *clapboardFrame;

- (instancetype)initFromFrame:(BKRFrame *)frame;
+ (instancetype)sceneFromFrame:(BKRFrame *)frame;
- (void)addFrame:(BKRFrame *)frame;
- (NSArray<BKRFrame *> *)allFrames;
- (NSArray<BKRDataFrame *> *)allDataFrames;
- (NSArray<BKRResponse *> *)allResponseFrames;
- (NSArray<BKRRequest *> *)allRequestFrames;
- (BKRRequest *)originalRequest;
- (BKRRequest *)currentRequest;


@end
