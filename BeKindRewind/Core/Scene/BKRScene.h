//
//  BKRScene.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRSerializer.h"

//@class BKRData;
//@class BKRRequest;
//@class BKRResponse;
@class BKRFrame;
@class BKRData;
@class BKRError;
@class BKRRequest;
@class BKRResponse;
@interface BKRScene : NSObject <BKRSerializer>

//- (instancetype)initWithTask:(NSURLSessionTask *)task;
//+ (instancetype)sceneWithTask:(NSURLSessionTask *)task;

@property (nonatomic, copy, readonly) NSString *uniqueIdentifier;
@property (nonatomic, copy, readonly) BKRFrame *clapboardFrame;

- (instancetype)initFromFrame:(BKRFrame *)frame;
+ (instancetype)sceneFromFrame:(BKRFrame *)frame;
- (void)addFrame:(BKRFrame *)frame;
- (NSArray<BKRFrame *> *)allFrames;
- (NSArray<BKRData *> *)allDataFrames;
- (NSArray<BKRResponse *> *)allResponseFrames;
- (NSArray<BKRRequest *> *)allRequestFrames;
- (BKRRequest *)originalRequest;
- (BKRRequest *)currentRequest;


@end
