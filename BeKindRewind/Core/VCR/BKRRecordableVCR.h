//
//  BKRRecordableVCR.h
//  Pods
//
//  Created by Jordan Zucker on 2/9/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRVCRActions.h"

@interface BKRRecordableVCR : NSObject <BKRVCRActions, BKRVCRRecording>

- (instancetype)initWithEmptyCassetteOption:(BOOL)shouldSaveEmptyCassette;
+ (instancetype)vcrWithCassetteSavingOption:(BOOL)shouldSaveEmptyCassette;

+ (instancetype)vcr;

@property (nonatomic, assign, readonly) BOOL shouldSaveEmptyCassette; // no by default

@end
