//
//  VCR.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <Foundation/Foundation.h>

@interface VCR : NSObject

@property (nonatomic, getter=isRecording) BOOL recording;

@property (nonatomic, getter=isDisabled) BOOL isDisabled;

@end
