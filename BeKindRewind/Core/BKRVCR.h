//
//  BKRVCR.h
//  Pods
//
//  Created by Jordan Zucker on 1/19/16.
//
//

#import <Foundation/Foundation.h>

@class BKRCassette;

@interface BKRVCR : NSObject

@property (nonatomic, getter=isRecording) BOOL recording;

@property (nonatomic, getter=isDisabled) BOOL isDisabled;

@property (nonatomic, strong) BKRCassette *currentCassette;

//- (instancetype)initWithCassette:(BKRCassette *)cassette;
//+ (instancetype)vcrWithCassette:(BKRCassette *)cassette;

//- (void)swizzleNetworkCallsForRecording;

@end
