//
//  BKRRecordableRawFrame.m
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import "BKRRecordableRawFrame.h"
#import "BKRDataFrame.h"
#import "BKRResponseFrame.h"
#import "BKRRequestFrame.h"

@implementation BKRRecordableRawFrame

- (BKRFrame *)editedFrame {
    if ([self.item isKindOfClass:[NSData class]]) {
        BKRDataFrame *dataFrame = [BKRDataFrame frameFromFrame:self];
        [dataFrame addData:self.item];
        return dataFrame;
    } else if ([self.item isKindOfClass:[NSURLResponse class]]) {
        BKRResponseFrame *responseFrame = [BKRResponseFrame frameFromFrame:self];
        [responseFrame addResponse:self.item];
        return responseFrame;
    } else if ([self.item isKindOfClass:[NSURLRequest class]]) {
        BKRRequestFrame *requestFrame = [BKRRequestFrame frameFromFrame:self];
        [requestFrame addRequest:self.item];
        return requestFrame;
    } else {
        return nil;
    }
}

@end
