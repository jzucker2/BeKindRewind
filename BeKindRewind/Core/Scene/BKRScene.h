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
@class BKRResponseFrame;
@interface BKRScene : NSObject

//@property (nonatomic, strong) NSMutableArray<BKRFrame *> *frames;
@property (nonatomic, copy) NSString *uniqueIdentifier;
@property (nonatomic, strong, readonly) BKRFrame *clapboardFrame;

- (void)addFrameToFramesArray:(BKRFrame *)frame;

- (NSArray<BKRFrame *> *)allFrames;
- (NSArray<BKRDataFrame *> *)allDataFrames;
- (NSArray<BKRResponseFrame *> *)allResponseFrames;
- (NSArray<BKRRequestFrame *> *)allRequestFrames;
- (NSArray<BKRErrorFrame *> *)allErrorFrames;
- (BKRRequestFrame *)originalRequest;
- (BKRRequestFrame *)currentRequest;


@end
