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
@class BKRError;
@class BKRRequestFrame;
@class BKRResponseFrame;
@interface BKRScene : NSObject

@property (nonatomic, strong) NSArray<BKRFrame *> *frames;
@property (nonatomic, copy) NSString *uniqueIdentifier;
@property (nonatomic, copy, readonly) BKRFrame *clapboardFrame;

- (NSArray<BKRFrame *> *)allFrames;
- (NSArray<BKRDataFrame *> *)allDataFrames;
- (NSArray<BKRResponseFrame *> *)allResponseFrames;
- (NSArray<BKRRequestFrame *> *)allRequestFrames;
- (BKRRequestFrame *)originalRequest;
- (BKRRequestFrame *)currentRequest;


@end
